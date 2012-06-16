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
    console.log(matches)
    return [] if matches is null

    @buildDateTimeObject(match) for match in matches

  # Parses a date time string and returns an object with all of its properties,
  # month, day, year, etc, and also the original string in the text property.
  buildDateTimeObject: (dateTimeString) ->
    split = @dateTimeRegExp().exec(dateTimeString)

    console.log(split)

    text:    split[0]
    month:   @findMonth(split[2], split[3])
    day:     @findDay(split[2], split[3])
    year:    @findYear(split[0])
    start:   @findStartHour(split[4])
    end:     @findEndHour(split[4])
    localStart: ->
      new Date("#{@month} #{@day} #{@year} #{@start} UTC")
    localEnd: ->
      return null if @end is null
      new Date("#{@month} #{@day} #{@year} #{@end} UTC")

  # If the first one matches a short or long month, it means that the order
  # was 19 June, so we use that first value. Otherwise, it was June 19,
  # and we use the second.
  findMonth: (firstMatch, secondMatch) ->
    if firstMatch in @monthsLong or firstMatch in @monthsShort
      firstMatch
    else
      secondMatch

  # If the first one matches one or more digits, it means that the order
  # was 19 June, so we use that first value. Otherwise, it was June 19,
  # and we use the second.
  findDay: (firstMatch, secondMatch) ->
    matches = firstMatch.match(/\d+/)
    if matches
      firstMatch
    else
      secondMatch

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
