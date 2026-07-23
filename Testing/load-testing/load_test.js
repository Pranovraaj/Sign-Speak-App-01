import http from 'k6/http';
import { check, sleep } from 'k6';

// 1. Setup the load testing options
export const options = {
    // Stage 1: Ramp up to 100 concurrent virtual users
    // Stage 2: Stay at 100 virtual users for 1 minute
    // Stage 3: Ramp down to 0
    stages: [
        { duration: '10s', target: 100 }, // Ramp up
        { duration: '1m', target: 100 },  // Maintain 100 concurrent users for 1 minute
        { duration: '10s', target: 0 },   // Ramp down
    ],
    thresholds: {
        // We want the average response time to be less than 250ms and 95% of requests to be less than 500ms
        http_req_duration: ['avg<250', 'p(95)<500'],
        // We want fewer than 1% of requests to fail
        http_req_failed: ['rate<0.01'],
    }
};

// 2. Define the main test execution function
export default function () {
    // Generate a random email to prevent duplicate email constraint violations if testing the register endpoint
    const randomId = Math.floor(Math.random() * 10000000);
    const payload = JSON.stringify({
        email: `testuser${randomId}@example.com`,
        password: 'Password123!',
        preferredVoice: 'default'
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
    };

    // Assuming the backend is running locally on port 8080
    const res = http.post('http://127.0.0.1:8080/api/auth/register', payload, params);

    // Validate the response
    check(res, {
        'is status 200 or 201 or 400': (r) => [200, 201, 400].includes(r.status), // Accept 400 if user exists, but ideally 200/201
    });

    // Pause briefly to simulate a real user waiting before their next action
    sleep(1);
}
