
# Blood Glucose Tracker App

This Flutter application is part of the Una Health Mobile Tech Challenge. It retrieves blood glucose data from an external API, plots it on a line graph, and allows users to filter the data by selecting start and end dates. The app also calculates and displays the minimum, maximum, average, and median blood glucose levels.

## Features

- Fetches blood glucose data from a static JSON API.
- Displays blood glucose levels over time on a line graph.
- Allows filtering by date (start and end dates), with date selection automatically restricted to available data.
- Displays calculated minimum, maximum, average, and median values of the filtered data.
- Automatically selects the first and last available dates as the default date range.
- Dark theme with a modern UI.
- Widget tests included.

## API

Data is retrieved from the following URL:  
`https://s3-de-central.profitbricks.com/una-health-frontend-tech-challenge/sample.json`

The response format is:
```json
{
  "bloodGlucoseSamples": [
    {
      "value": "8.9",
      "timestamp": "<ISO 8601 timestamp>",
      "unit": "mmol/L"
    },
    {
      "value": "5.9",
      "timestamp": "<ISO 8601 timestamp>",
      "unit": "mmol/L"
    }
  ]
}
```

## How to Run

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Use `flutter run` to run the app on an emulator or connected device.

## Widget Tests

Widget tests are located in the `test` directory. Run the tests using:
```bash
flutter test
```

## Bonus

- The minimum, maximum, average, and median values are calculated and displayed alongside the graph.
- Date selection is automatically restricted to available dates from the API response.
- Widget tests have been implemented for the main screen.
