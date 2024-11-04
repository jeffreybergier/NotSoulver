## Stop on Exception
fb -[NSException raise]
fb +[XPLog pause:]

## Remove later
fb -[SVRSettingsViewController themeChanged:]
fb -[SVRSettingsViewController timeChanged:]
fb -[SVRSettingsViewController timeReset:]

## Run automatically
run
