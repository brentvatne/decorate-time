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
    ///gm

  findDateTimeExpressions: (text) ->
    @dateTimeRegExp().exec(text)


    #for token in text.split(" ")
    #  if token in @months or token in @monthsShort
    #    return true


window.DecorateTime = DecorateTime
