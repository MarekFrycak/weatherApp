# weatherApp

WeatherApp Readme

created by: Marek Fryčák

Introduction
WeatherApp is a Swift-based iOS application that provides users with real-time weather information and a 12-hour weather forecast for their current location. It utilizes the AccuWeather API to fetch weather data and provides a user-friendly interface to display this information.

Features
Display current weather conditions, including temperature and weather description.
Show an icon representing the current weather.
Provide the user's current location name.
Display a 12-hour weather forecast with temperature and weather description for each hour.
Support for both light and dark mode.
Customizable fonts and layout based on device size.


Installation
Clone the WeatherApp repository from GitHub:  https://github.com/MarekFrycak/weatherApp.git
Open the project in Xcode by double-clicking on the `WeatherApp.xcodeproj` file.
Make sure you have Xcode installed on your Mac.
Make sure you have Alamofire installed from package manager.
Build and run the project on a simulator or a physical iOS device.


Usage
1. Upon launching the app, you will be prompted to grant location access to the app. Allow it to 	access your location to fetch accurate weather data.
2. The main screen will display the following information:
   - Location name
   - Current temperature
   - Current weather description
   - Weather icon representing the current conditions
   - A 12-hour weather forecast
3. You can swipe left or right on the 12-hour forecast to view weather information for different 		hours.
4. The background color of the app changes based on the current weather conditions, creating a visual representation of the weather.


Layout
The app's layout is designed to adapt to different device sizes and orientations.


Icons
The weather icons used in the app are named according to the AccuWeather API's weather icon codes.
Dependencies
The WeatherApp uses the following dependencies:

- Alamofire: Used for making HTTP requests to fetch weather data from the AccuWeather API.

Make sure to install these dependencies using a package manager like CocoaPods or Swift Package Manager before building the project.


API Key
The WeatherApp requires an API key from AccuWeather to fetch weather data. You should replace the placeholder `ApiKey1` in the `ViewController.swift` file with your actual API key.


Mock Data
To ensure the app works even without a network connection or API key, it includes mock data for weather information. You can replace the mock JSON data files in the project with your own data if needed.


Troubleshooting
If you encounter any issues or have questions about the WeatherApp, feel free to reach out to me for assistance.


License
The WeatherApp is open-source software.


Acknowledgments
The WeatherApp was created by Marek Fryčák on 11.11.2023. Special thanks to the AccuWeather API for providing weather data.


Enjoy using the WeatherApp to stay informed about the weather in your area!
