<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class BlackwallService
{
    protected string $url;

    public function __construct()
    {
        // This combines your .env URL with the exact endpoint we just tested
        $baseUrl = env('BLACKWALL_API_URL', 'http://127.0.0.1:8000');
        $this->url = rtrim($baseUrl, '/') . '/analyze';
    }

    public function isSafe(string $text): bool
    {
        try {
            // Laravel sends the exact same POST request your test2.sh script just did
            $response = Http::timeout(5)->post($this->url, [
                'text' => $text
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                // Based on your terminal output, class_id 0 is "Safe"
                return isset($data['class_id']) && $data['class_id'] === 0;
            }

            Log::error('Blackwall API Error: ' . $response->status());
            return false;

        } catch (\Exception $e) {
            Log::error('Blackwall Connection Failed: ' . $e->getMessage());
            return false;
        }
    }
}