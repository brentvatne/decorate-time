DecorateTime =
  monthsLong: [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December'
  ]

  monthsShort: [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ]

  dateTimeRegExp: ->
    months      = @monthsLong.join("|")
    monthsShort = @monthsShort.join("|")

    ///
      (#{months}|#{monthsShort}|\d+)
      \s+
      (#{months}|#{monthsShort}|\d+)
      (.*?)
      (UTC)
    ///g

  findDateTimeExpressions: (text) ->
    matches = text.match(@dateTimeRegExp())
    return [] if matches is null

    result = for match in matches
      @buildDateTimeObject(match)
    console.log result
    result

  findMonth: (split) ->

  findDay: (split) ->

  findYear: (split) ->
    matches = split[0].match(/\d{4}/) || []
    matches[0] || @currentYear()

  findStart: (split) ->

  findEnd: (split) ->

  buildDateTimeObject: (dateTimeString) ->
    split = @dateTimeRegExp().exec(dateTimeString)

    text:  split[0]
    month: @findMonth(split)
    day:   @findDay(split)
    year:  @findYear(split)

    # build an object
    # { text: '..',
    #   month: '..',
    #   day: '..',
    #   year: '..',
    #   start: '..',
    #   end: '..' }

  currentYear: ->
    (new Date).getFullYear().toString()

    #for token in text.split(" ")
    #  if token in @months or token in @monthsShort
    #    return true


window.DecorateTime = DecorateTime
