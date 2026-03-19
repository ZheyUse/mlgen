<?php
/**
 * generate-file-remote.php
 *
 * Loader stub that fetches the real `generate-file-structure.php` from a remote
 * location and executes it. Configure the URL below to point to your hosted
 * generator (raw PHP file). If fetching fails, the stub prints a helpful error.
 */

declare(strict_types=1);

// TODO: set this to the raw URL where your generator lives (HTTPS required)
$remoteUrl = getenv('ML_GENERATOR_URL') ?: 'https://raw.githubusercontent.com/ZheyUse/mlgen/main/generate-file-structure.php';

function fetchRemote(string $url): ?string
{
    // Try cURL first
    if (function_exists('curl_version')) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        $body = curl_exec($ch);
        $ok = curl_getinfo($ch, CURLINFO_HTTP_CODE) === 200 && $body !== false;
        curl_close($ch);
        return $ok ? $body : null;
    }

    // Fallback to file_get_contents if allowed
    $opts = stream_context_create(['http' => ['timeout' => 15]]);
    $body = @file_get_contents($url, false, $opts);
    if ($body === false) {
        return null;
    }

    return $body;
}

$code = fetchRemote($remoteUrl);
if ($code === null) {
    fwrite(STDERR, "[ERROR] Failed to fetch remote generator: {$remoteUrl}\n");
    fwrite(STDERR, "Set the environment variable ML_GENERATOR_URL to point to your generator URL, or install the full generator locally.\n");
    exit(2);
}

// Save to a temp file and require it to run in current process.
$temp = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'ml_generator_' . bin2hex(random_bytes(8)) . '.php';
if (file_put_contents($temp, $code) === false) {
    fwrite(STDERR, "[ERROR] Failed to write temporary generator file.\n");
    exit(3);
}

// Execute the fetched generator
require $temp;

// Cleanup
@unlink($temp);

