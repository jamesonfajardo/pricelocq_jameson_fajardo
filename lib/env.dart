// environment constants
// this file contains the important values within the app

const kLoginEndpoint = 'https://stable-api.pricelocq.com/mobile/v2/sessions';
const kStationEndpoint = 'https://stable-api.pricelocq.com/mobile/stations?all';

// Google Maps API Key: AIzaSyAxpEhtNF09ohHKi4Jnglho3zOYEEAdfoM
// i used my own API key for google map because ios permission is not
// allowed in the old API key

// used a different method ( Haversine formula ) on fetching distance between 2 points
// because google's geocoding service is paid.
// please refer to google's notice below
// You must enable Billing on the Google Cloud Project at
//https://console.cloud.google.com/project/_/billing/enable
//Learn more at https://developers.google.com/maps/gmp-get-started