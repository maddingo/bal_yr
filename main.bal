import ballerina/io;
import ballerina/http;
import ballerina/os;

type PlaceLatLon record {|
    decimal lat;
    decimal lng;
|};

type PlaceViewport record {|
    PlaceLatLon northeast;
    PlaceLatLon southwest;
|};

type PlaceGeometry record {|
    PlaceLatLon location;
    PlaceViewport viewport;
|};

type PlaceCandidate record {|
    PlaceGeometry geometry;
|};

type PlaceResponse record {|
    PlaceCandidate[] candidates;
    string status;
|};

public function main() returns error? {

    PlaceLatLon[] locations = check getCoordinatesFromAddress("Randaberg");

    foreach var location in  locations {
        http:Client forecastApi = check new ("https://api.met.no/weatherapi/locationforecast/2.0/compact/");
        json respForecast = check forecastApi->get(latLonPart(location.lat, location.lng));
        io:println(respForecast);
    }
}

function getCoordinatesFromAddress(string address) returns PlaceLatLon[]|error {
    string apiKey = os:getEnv("GOOGLE_PLACE_API_KEY");

    http:Client placesApi = check new ("https://maps.googleapis.com");
    json respPlace = check placesApi->get("/maps/api/place/findplacefromtext/json?input=" + address+ "&inputtype=textquery&fields=geometry&key=" + apiKey);

    io:println(respPlace);

    PlaceResponse pr = check respPlace.cloneWithType();

    PlaceLatLon[] locations = []; 

    foreach var candidate in pr.candidates {
        io:println(candidate.geometry.location);
        locations.push(candidate.geometry.location);
    }

    return locations;
}

function latLonPart(decimal lat, decimal lon) returns string {
    
    return "?lat=" + lat.toString() + "&lon=" + lon.toString();
}
