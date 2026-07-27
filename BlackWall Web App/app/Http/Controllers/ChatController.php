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
        $userText = $request->message;

        // 1. Check if User's prompt is safe via Python Blackwall
        if (!$this->blackwall->isSafe($userText)) {
            return response()->json([
                'status' => 'rejected',
                'reason' => 'User input flagged as unsafe.'
            ], 403);
        }

        // 2. Call the REAL Gemini API
        $aiContent = $this->askExternalAI($userText);

        if (!$aiContent) {
            return response()->json([
                'status' => 'error',
                'reason' => 'Failed to get a response from the AI.'
            ], 500);
        }

        // 3. Check if AI's response is safe via Python Blackwall
        if (!$this->blackwall->isSafe($aiContent)) {
            return response()->json([
                'status' => 'rejected',
                'reason' => 'AI output flagged as unsafe.'
            ], 403);
        }

        // 4. Return the safe AI response to the user
        return response()->json([
            'status' => 'success',
            'response' => $aiContent
        ]);
    }

     
    
    /**
     * Calls the Google Gemini API to generate a response.
     */
    private function askExternalAI(string $prompt): ?string
    {
        $apiKey = env('GEMINI_API_KEY');

        if (empty($apiKey)) {
            Log::error('Gemini API key is missing from .env');
            return null;
        }

        try {
            // Using gemini-1.5-flash as it is the fastest and most efficient for chat
            $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={$apiKey}";

            $response = Http::timeout(15)
                ->withHeaders([
                    'Content-Type' => 'application/json',
                ])
                ->post($url, [
                    'contents' => [
                        [
                            'parts' => [
                                ['text' => $prompt]
                            ]
                        ]
                    ]
                ]);

            if ($response->successful()) {
                // Extract the text from Gemini's JSON response structure
                return $response->json('candidates.0.content.parts.0.text');
            }

            // Log the exact error if Gemini rejects the request
            Log::error('Gemini API Error: ' . $response->body());
            return null;

        } catch (\Exception $e) {
            Log::error('Failed to connect to Gemini: ' . $e->getMessage());
            return null;
        }
    }
}