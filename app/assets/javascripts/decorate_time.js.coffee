DecorateTime =
  monthsLong: [
    'January', 'February', 'March', 'April', 'May',
    'June', 'July', 'August', 'September', 'October',
    'November', 'December'
  ]

  monthsShort: [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ]

  # 
  eachIn: (elements, callback) ->
    for element in elements
      element   = $(element)
      dateTimes = @findDateTimeExpressions(element.html())

      for dateTime in dateTimes
        currentHtml = element.html()
        newText     = callback(dateTime)

        unless currentHtml.indexOf(newText) > 0
          newHtml = currentHtml.replace(
            ///#{dateTime.text}///g, newText
          )
          element.html(newHtml)

  # Matches strings such as:
  #
  # 19 June from 20:00 - 21:00 UTC
  # June 19 at 20:00 UTC
  # June 19 from 21:00 to 23:00 UTC
  #
  # Must contain UTC at the end of the string to match.
  dateTimeRegExp: ->
    months      = @monthsLong.join("|")
    monthsShort = @monthsShort.join("|")

    ///
      (#{months}|#{monthsShort}|\d+)  # It's either June 19
      \s+                             # or 19 June, and this
      (#{months}|#{monthsShort}|\d+)  # handles both cases.
      (.*?)                           # Any non-greedy match
      (UTC)                           # Until UTC is found
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

    text:  split[0]
    month: @findMonth(split)
    day:   @findDay(split)
    year:  @findYear(split)
    start: @findStartHour(split)
    end:   @findEndHour(split)
    localStart: ->
      new Date("#{@month} #{@day} #{@year} #{@start} UTC")
    localEnd: ->
      return null if @end is null
      new Date("#{@month} #{@day} #{@year} #{@end} UTC")


  # If the first one matches a short or long month, it means that the order
  # was 19 June, so we use that first value. Otherwise, it was June 19,
  # and we use the second.
  findMonth: (split) ->
    if split[1] in @monthsLong or split[1] in @monthsShort
      split[1]
    else
      split[2]

  # If the first one matches one or more digits, it means that the order
  # was 19 June, so we use that first value. Otherwise, it was June 19,
  # and we use the second.
  findDay: (split) ->
    matches = split[1].match(/\d+/)
    if matches
      split[1]
    else
      split[2]

  # Look in the fulltext for any substring of four consecutive digits, otherwise
  # use the current year.
  findYear: (split) ->
    matches = split[0].match(/\d{4}/) || []
    matches[0] || @currentYear()

  # Look in the part in between June 19 and UTC a string like June 19 from
  # 20:00 to 21:00 UTC for the first occurrence of two digits:two digits.
  findStartHour: (split) ->
    matches = split[3].match(/\d+:\d+/)
    matches[0]

  # Look in the part in between June 19 and UTC a string like June 19 from
  # 20:00 to 21:00 UTC for the second occurrence of two digits:two digits.
  findEndHour: (split) ->
    matches = split[3].match(/\d+:\d+/g)
    matches[1] || null

  # Returns the current year as a String
  currentYear: ->
    (new Date).getFullYear().toString()

window.DecorateTime = DecorateTime
