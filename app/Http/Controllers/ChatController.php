<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\BlackwallService;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class ChatController extends Controller
{
    protected $blackwall;

    public function __construct(BlackwallService $blackwall)
    {
        $this->blackwall = $blackwall;
    }

    public function sendMessage(Request $request)
    {
        $request->validate(['message' => 'required|string']);
        $rawText = trim($request->message);

        // 1. Process @blackwall command if present
        $userText = $rawText;
        if (preg_match('/^@blackwall\b\s*/i', $rawText)) {
            $userText = trim(preg_replace('/^@blackwall\b\s*/i', '', $rawText));
            if (empty($userText)) {
                return response()->json([
                    'status' => 'success',
                    'response' => '🛡️ **BlackWall Command Listener Active**\nPlease specify your query following `@blackwall`, e.g.:\n`@blackwall Explain quantum cryptography`'
                ]);
            }
        }

        // 2. Pass prompt through Blackwall Security Layer
        if (!$this->blackwall->isSafe($userText)) {
            return response()->json([
                'status' => 'rejected',
                'reason' => 'User prompt flagged as unsafe by BlackWall security policies.'
            ], 403);
        }

        // 3. Call local Ollama AI backend
        $aiContent = $this->askOllama($userText);

        if (!$aiContent) {
            return response()->json([
                'status' => 'error',
                'reason' => 'Failed to retrieve response from local Ollama model.'
            ], 500);
        }

        // 4. Pass generated AI response through Blackwall Security Layer
        if (!$this->blackwall->isSafe($aiContent)) {
            return response()->json([
                'status' => 'rejected',
                'reason' => 'AI output flagged as unsafe by BlackWall security policies.'
            ], 403);
        }

        // 5. Return safe AI response
        return response()->json([
            'status' => 'success',
            'response' => $aiContent
        ]);
    }

    /**
     * Calls local Ollama REST API endpoint to generate response.
     */
    private function askOllama(string $prompt): ?string
    {
        $baseUrl = env('OLLAMA_BASE_URL', 'http://localhost:11434');
        $model = env('OLLAMA_MODEL', 'qwen3.6:latest');

        try {
            $response = Http::timeout(120)
                ->withHeaders(['Content-Type' => 'application/json'])
                ->post(rtrim($baseUrl, '/') . '/api/generate', [
                    'model' => $model,
                    'prompt' => $prompt,
                    'stream' => false,
                ]);

            if ($response->successful()) {
                return $response->json('response');
            }

            Log::error('Ollama API Error: ' . $response->body());
            return null;

        } catch (\Exception $e) {
            Log::error('Failed to connect to Ollama: ' . $e->getMessage());
            return null;
        }
    }
}