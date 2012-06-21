DecorateTime =
  monthsLong: [
    'January', 'February', 'March', 'April',
    'May', 'June', 'July', 'August', 'September',
    'October', 'November', 'December'
  ]

  monthsShort: [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ]

  daysLong: [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ]

  daysShort: [
    'Mon', 'Tues', 'Weds', 'Thurs', 'Fri', 'Sat', 'Sun'
  ]

  # Matches strings such as:
  #
  # 19 June from 20:00 - 21:00 UTC
  # June 19 at 20:00 UTC
  # June 19 from 21:00 to 23:00 UTC
  # 20:00 UTC
  #
  # Must contain UTC at the end of the string to match.
  dateTimeRegExp: ->
    monthsLong  = @monthsLong.join("|")
    monthsShort = @monthsShort.join("|")
    daysLong    = @daysLong.join("|")
    daysShort   = @daysShort.join("|")
    time        = "(\\d+:\\d+)"

    ///
      (?:(?:(#{daysLong}|#{daysShort}),\s+)? # Friday | Fri, space
      (#{monthsLong}|#{monthsShort}|\d+)  # June | Jun | 10
      (?:[,\s+])?                         # , space
      (#{monthsLong}|#{monthsShort}|\d+)  # June | Jun | 10
      (?:[^\d]+))?                           # from | between | at .. etc
      (#{time}(?:.*?)#{time}?)              # 12:00 - 14:00 between 13:00 to 15:00
      \s+                                 # One or more spaces
      (UTC)                               # Until UTC is found.
    ///ig

  # Finds each UTC date in the given elements and replaces it with the value 
  # returned from callback(the date time object)
  eachIn: (elements, callback) ->
    for element in elements
      element   = $(element)
      dateTimes = @findDateTimeExpressions(element.html())

      for dateTime in dateTimes
        currentHtml = element.html()
        newText     = callback(dateTime)

        unless @alreadyReplaced(currentHtml, newText)
          newHtml = currentHtml.replace(
            ///#{dateTime.utc.text}///g, newText
          )
          element.html(newHtml)

  # Determines if the html already contains the given text
  #
  # This is used to get over the edge case of one element
  # containing the same date more than one.
  #
  # Returns true if it does contain it, false if not.
  alreadyReplaced: (html, text) ->
    html.indexOf(text) > 0

  # Searches a block of text (eg: a paragraph) for any suitable date time
  # strings. It then returns an Array of objects containing the parsed
  # data for each date time and their original text.
  findDateTimeExpressions: (text) ->
    matches = text.match(@dateTimeRegExp())
    return [] if matches is null

    @buildDateTimeObject(match) for match in matches

  # Parses a date time string and returns an object with all of its properties,
  # month, day, year, etc, and also the original string in the text property.
  buildDateTimeObject: (dateTimeString) ->
    utcData   = @extractUtcData(dateTimeString)
    localData = @convertToLocalData(utcData)

    utc:   utcData
    local: localData

  extractUtcData: (dateTimeString) ->
    split = @dateTimeRegExp().exec(dateTimeString)
    console.log split

    data =
      text:  dateTimeString
      month: @findMonth(split[2], split[3])
      date:  @findDate(split[2], split[3])
      year:  @findYear(split[0])
      start: @findStartHour(split[4])
      end:   @findEndHour(split[4])

    @sanitizeData(data)

  convertToLocalData: (utcData) ->
    startDate = @initializeDate(utcData, utcData.start)
    endDate   = @initializeDate(utcData, utcData.end)

    month  = @monthsLong[startDate.getMonth()]
    day    = @daysLong[startDate.getDay()]
    date   = startDate.getDate().toString()
    year   = startDate.getFullYear().toString()
    start  = @timeStringFromDate(startDate)
    end    = @timeStringFromDate(endDate)
    offset = @findLocalOffset()

    text = utcData.text.replace(utcData.day, day).
                        replace(utcData.date, date).
                        replace(utcData.month, month).
                        replace(utcData.start, start).
                        replace(utcData.end, end).
                        replace('UTC', offset)

    text:   text
    month:  month
    date:   date
    year:   year
    start:  start
    end:    end
    offset: offset

  sanitizeData: (data) ->
    if data.month is undefined
      data.month = @monthsLong[@currentMonth()]
      data.date  = @currentDate()
      data.year  = @currentYear()

    data

  initializeDate: (data, hour, timezone='UTC') ->
    return '' if hour is null

    new Date("#{data.month} #{data.date} #{data.year} #{hour} #{timezone}")

  # Gets the timezone offset from UTC and returns it as a String,
  # for example 'UTC-7'
  findLocalOffset: ->
    offset = ((new Date).getTimezoneOffset() / 60) * -1
    "UTC#{offset.toString()}"

  # Creates a formatted time string from a given Date object, or null
  # if the date is an empty string.
  #
  # Example: '10:03' (rather than '10:3')
  timeStringFromDate: (date) ->
    return null if date is ''
    hour    = date.getHours().toString()
    minutes = date.getMinutes().toString()

    if hour.length is 1
      hour = "0" + hour

    if minutes.length is 1
      minutes = "0" + minutes

    "#{hour}:#{minutes}"

  # If the first one matches a short or long month, it means that the order
  # was 19 June, so we use that first value. Otherwise, it was June 19,
  # and we use the second.
  findMonth: (possibleSource, otherPossibleSource) ->
    if possibleSource in @monthsLong or possibleSource in @monthsShort
      possibleSource
    else
      otherPossibleSource

  # If the first one matches one or more digits, it means that the order
  # was 19 June, so we use that first value. Otherwise, it was June 19,
  # and we use the second.
  findDate: (possibleSource='', otherPossibleSource='') ->
    matches = possibleSource.match(/\d+/)
    if matches
      possibleSource
    else
      otherPossibleSource

  # Look in the fulltext for any substring of four consecutive digits, otherwise
  # use the current year.
  findYear: (fullText) ->
    matches = fullText.match(/\d{4}/) || []
    matches[0] || @currentYear()

  # Look in the part in between June 19 and UTC a string like June 19 from
  # 20:00 to 21:00 UTC for the first occurrence of two digits:two digits.
  findStartHour: (timePortion) ->
    matches = timePortion.match(/\d+:\d+/)
    matches[0]

  # Look in the part in between June 19 and UTC a string like June 19 from
  # 20:00 to 21:00 UTC for the second occurrence of two digits:two digits.
  findEndHour: (timePortion) ->
    matches = timePortion.match(/\d+:\d+/g)
    matches[1] || null

  # Returns the current year as a String
  currentYear: ->
    (new Date).getFullYear().toString()

  # Returns the current month as a String
  currentMonth: ->
    (new Date).getMonth().toString()

  # Returns the current date as a String
  currentDate: ->
    (new Date).getDate().toString()

window.DecorateTime = DecorateTime
