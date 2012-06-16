DecorateTime =
  monthsLong: [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ]

  monthsShort: [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ]

  daysLong: [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
  ]

  daysShort: [
    'Mon', 'Tues', 'Weds', 'Thurs', 'Fri', 'Sat', 'Sun'
  ]

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
            ///#{dateTime.text}///g, newText
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

  # Matches strings such as:
  #
  # 19 June from 20:00 - 21:00 UTC
  # June 19 at 20:00 UTC
  # June 19 from 21:00 to 23:00 UTC
  #
  # Must contain UTC at the end of the string to match.
  dateTimeRegExp: ->
    monthsLong  = @monthsLong.join("|")
    monthsShort = @monthsShort.join("|")
    daysLong    = @daysLong.join("|")
    daysShort   = @daysShort.join("|")

    ///
      (?:(#{daysLong}|#{daysShort}),\s+)? # First maybe a day comma space
      (#{monthsLong}|#{monthsShort}|\d+)  # It's either June 19 or 19 June,
      [,\s+]                              # and this handles both cases.
      (#{monthsLong}|#{monthsShort}|\d+)  #
      (.*?)                               # Any non-greedy match in between.
      (UTC)                               # Until UTC is found.
    ///ig

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
    split = @dateTimeRegExp().exec(dateTimeString)

    text  = split[0]
    month = @findMonth(split[2], split[3])
    date  = @findDate(split[2], split[3])
    year  = @findYear(split[0])
    start = @findStartHour(split[4])
    end   = @findEndHour(split[4])

    startDate = new Date("#{month} #{date} #{year} #{start} UTC")

    if end
      endDate = new Date("#{month} #{date} #{year} #{end} UTC")
    else
      endDate = ''

    text:      text
    startDate: startDate
    endDate:   endDate
    utc:
      month: month
      date:  date
      year:  year
      start: start
      end:   end
    local:
      month:  @monthsLong[startDate.getMonth()]
      date:   startDate.getDate().toString()
      year:   startDate.getFullYear().toString()
      start:  @timeStringFromDate(startDate)
      end:    @timeStringFromDate(endDate)
      offset: @findLocalOffset()

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
  findDate: (possibleSource, otherPossibleSource) ->
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

window.DecorateTime = DecorateTime
