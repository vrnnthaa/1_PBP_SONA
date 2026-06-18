<?php

namespace App\Services;

use Google_Client;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    /**
     * Mengirimkan Push Notification via Firebase HTTP v1 API.
     *
     * @param string $fcmToken Token FCM tujuan (dari tabel users)
     * @param string $title Judul notifikasi
     * @param string $body Isi pesan notifikasi
     * @param array $data Data tambahan (opsional) untuk diproses di background Flutter
     * @return array
     */
    public static function sendNotification($fcmToken, $title, $body, $data = [])
    {
        try {
            $credentialsFilePath = storage_path(env('FIREBASE_CREDENTIALS_PATH'));

            $client = new Google_Client();
            $client->setAuthConfig($credentialsFilePath);
            $client->addScope('https://www.googleapis.com/auth/firebase.messaging');

            $tokenInfo = $client->fetchAccessTokenWithAssertion();
            $accessToken = $tokenInfo['access_token'];

            $credentials = json_decode(file_get_contents($credentialsFilePath), true);
            $projectId = $credentials['project_id'];

            $payload = [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body' => $body,
                    ],
                    'data' => empty($data) ? null : $data, // Opsional
                ],
            ];

            if (empty($data)) {
                unset($payload['message']['data']);
            }

            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type' => 'application/json',
            ])->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", $payload);

            return $response->json();

        } catch (\Exception $e) {
            Log::error('FCM Send Error: ' . $e->getMessage());
            return ['error' => $e->getMessage()];
        }
    }
}