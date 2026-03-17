{ ... }:
{
  programs.noctalia-shell.settings = {
    location = {
      name = "St_Johns";
      weatherEnabled = true;
      weatherShowEffects = true;
      useFahrenheit = false;
      use12hourFormat = false;
      showWeekNumberInCalendar = false;
      showCalendarEvents = true;
      showCalendarWeather = true;
      analogClockInCalendar = false;
      firstDayOfWeek = -1;
      hideWeatherTimezone = false;
      hideWeatherCityName = false;
    };
  };
}
