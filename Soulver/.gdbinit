## Stop on Exception
fb -[NSException raise]
fb +[XPLog pause:]

## Remove later
fb -[SVRSettingsViewController themeChanged:]
fb -[SVRSettingsViewController fontChangeRequest:]
fb -[SVRSettingsViewController timeChanged:]
fb -[SVRSettingsViewController fontReset:]
fb -[SVRSettingsViewController timeReset:]


## Run automatically
run
