#= require decorate_time

describe 'DecorateTime', ->
  describe 'findDateTimeExpressions', ->
    it 'finds expressions beginning with a month', ->
      result = DecorateTime.findDateTimeExpressions(
        'June 19 from 20:00 - 21:00 UTC'
      )
      expect(result).toBeTruthy()

    it 'finds expressions beginning with a day', ->
      result = DecorateTime.findDateTimeExpressions(
        '19 June from 20:00 - 21:00 UTC'
      )
      expect(result).toBeTruthy()

    it 'does not find expressions without UTC', ->
      result = DecorateTime.findDateTimeExpressions(
        '19 June from 20:00 - 21:00'
      )
      expect(result).toEqual([])

    it 'it detects date time strings in large blocks of text', ->
      paragraph = """
                  Please join us on June 19 from 20:00 - 21:00 UTC for a group discussion on
                  how to best keep database wrapping and domain logic separated in different
                  objects. The next one will be August 20 from 19:00 - 20:00 UTC, remember!
                  """

      result = DecorateTime.findDateTimeExpressions(paragraph)
      expect(result.length).toEqual(2)

    describe 'result object', ->
      beforeEach ->
        @sample      = '19 June at 20:00 UTC'
        @result      = DecorateTime.findDateTimeExpressions(@sample)

      it 'sets the text property to the full match', ->
        expect(@result[0].text).toEqual(@sample)

      it 'sets the year to the current year if not given', ->
        expect(@result[0].year).toEqual('2012')

      it 'sets the year to the one in the string, if given', ->
        result = DecorateTime.findDateTimeExpressions('19 June 2011 at 20:00 UTC')
        expect(result[0].year).toEqual('2011')

      it 'sets the month', ->
        expect(@result[0].month).toEqual('June')

      it 'sets the day', ->
        expect(@result[0].day).toEqual('19')

      it 'sets the start hour', ->
        expect(@result[0].start).toEqual('20:00')

      it 'sets the end hour', ->
        rangeSample = '19 June from 20:00 - 21:00 UTC'
        result = DecorateTime.findDateTimeExpressions(rangeSample)

        expect(result[0].end).toEqual('21:00')

  describe 'eachIn', ->
    beforeEach ->
      $('#testArea').empty()
      $('body').append(
        '<div style="display: none" id="testArea">'
      )
      $('#testArea').append(
        '<p>Hello there June 19 from 20:00 - 21:00 UTC</p>'
      )
      $('#testArea').append(
        '<p>August 3rd at 22:00 UTC is the first thing here.</p>'
      )

    it 'replaces the text with the value in the callback', ->
      DecorateTime.eachIn($('#testArea p'), (dateTime) ->
        "BRENT VATNE"
      )

      firstP = $('#testArea p').first().html()
      lastP  = $('#testArea p').last().html()

      expect(firstP.match(/BRENT VATNE/)).toBeTruthy()
      expect(lastP.match(/BRENT VATNE/)).toBeTruthy()

    it 'works like it says in the README', ->
      DecorateTime.eachIn $('p'), (dateTime) ->
        start = dateTime.localStart().toString()
        end   = (dateTime.localEnd() || "").toString()

        "<span class='date-time' data-start='#{start}' data-end='#{end}'>#{dateTime.text}</span>"

      paragraph = $('#testArea p').first().html()
      expect(paragraph.match('data-start="Tue Jun 19 2012')).toBeTruthy()
