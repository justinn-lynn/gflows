# Change

## Configuration
No need to configure a specific URL for the data source in the configuration files, as the project now uses the Polygon API.

```ini
# Auto-response to prompts for downloading recent data. If not set, user input is requested.
AUTO_RESPONSE=y

# Comma-separated ticker symbols to be initially loaded.
TICKERS=SPY,QQQ,NVDA,SMCI

# Your Polygon API key.
POLYGON_API_KEY=<YOUR_API_KEY>
```

## Features

- **Dynamic Ticker Management:** Users can add or remove ticker tabs through the UI, with changes synchronized in real-time across different clients on the server.
- **Frequent Updates:** Data refresh rate has been increased to every 10 minutes from the previous 15 minutes, ensuring more current data is displayed.
- **Server Deployment:** The application is currently deployed on a server accessible via SSH at `45.32.11.144` on port `80`.

## Logging

- **deploy.log:** Tracks the deployment process.
- **app.log:** Records runtime events and interactions.

Both logs are stored under the `log` directory within the project structure.

## Deployment

Deployment is managed via GitHub Actions:

- **Trigger:** Any push or approved merge to the `main` branch will trigger the deployment process.
- **Process:** The `deploy.sh` script is executed to automatically pull the latest code from the GitHub repository and restart the application.
- For detailed steps, see the `deploy.sh` script and the GitHub Actions workflow in `.github/workflows/deploy.yml`.

# G|Flows

G|Flows, or Greek Flows, provides 15-minute updates for the SPX, NDX, and RUT indexes every Monday-Friday from 9:00am-4:30pm ET.

## Features

### Measure by date & strike price:

- Delta, gamma, vanna, and charm exposure for stocks/indexes
- Implied volatility (IV) average

### Expirations to choose:

- All expirations
- Current month
- Current monthly OPEX
- 0DTE, if available, otherwise the closest expiration

### Guide:

- Need a refresh? View the meaning behind each greek and how their flows can be interpreted

## Setup

This application is compatible with Python versions **>=3.9**

### Virtual Environment (Recommended)

For an isolated package installation, create and activate a virtual environment:

```bash
# Create venv
$ python -m venv venv
```

Activation:

- Linux/Mac:

  ```bash
  $ source venv/bin/activate
  ```

- Windows:

  ```bash
  # Command Prompt
  $ venv\Scripts\activate.bat

  # PowerShell
  $ venv\Scripts\Activate.ps1
  ```

### Install Required Packages

```bash
$ pip install -r requirements.txt
```

### Configuration:

Create a .env file in the project's working directory to configure the app, otherwise the app will use default values:

```ini
# For downloading options data. If not set, the app defaults to a CBOE API — see ticker_dwn for info
API_URL=YOURAPIURL
# Auto-respond to prompt 'Download recent data? (y/n)'. If not set, user input is requested
AUTO_RESPONSE=y
# Default. Choose tickers from https://finance.yahoo.com/lookup (excluding futures)
TICKERS=^SPX,^NDX,^RUT
```

`app.py`:

G|Flows uses a scheduler to periodically redownload options data. To disable it, comment out this code

```python
"""
# schedule when to redownload data
sched = BackgroundScheduler(daemon=True)
sched.add_job(
    sensor,
    combining.OrTrigger(
        [
            cron.CronTrigger.from_crontab(
                "0,15,30,45 9-15 * * 0-4", timezone=timezone("America/New_York")
            ),
            cron.CronTrigger.from_crontab(
                "0,15,30 16 * * 0-4", timezone=timezone("America/New_York")
            ),
        ]
    ),
)
sched.add_job(
    check_for_retry,
    combining.OrTrigger(
        [
            cron.CronTrigger(
                day_of_week="0-4",
                hour="9-15",
                second="*/5",
                timezone=timezone("America/New_York"),
            ),
            cron.CronTrigger(
                day_of_week="0-4",
                hour="16",
                minute="0-30",
                second="*/5",
                timezone=timezone("America/New_York"),
            ),
        ]  # during the specified times, check every 5 seconds for a retry condition
    ),
)
sched.start()
"""
```

To analyze CSV data, change the **is_json** value to **False** within the **analyze_data** function

```python
def analyze_data(ticker, expir):
    # Analyze stored data of specified ticker and expiry
    # defaults: json format, timezone 'America/New_York'
    result = get_options_data(
        ticker,
        expir,
        is_json=True,  # False for CSV
        tz="America/New_York",
    )
    ...
```

For manual updates, CSV-formatted options data can be downloaded [here](https://www.cboe.com/delayed_quotes/cboe/quote_table) then placed in the `data/csv` directory

---

Upon completion, run the Dash app (available at http://localhost:8050):

```bash
$ python app.py
```
