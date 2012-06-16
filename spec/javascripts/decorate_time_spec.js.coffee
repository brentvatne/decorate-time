#= require decorate_time

describe 'DecorateTime', ->
  describe 'findDateTimeExpressions', ->
    it 'finds expressions beginning with a month', ->
      result = DecorateTime.findDateTimeExpressions(
        'Monday, June 19 from 20:00 - 21:00 UTC'
      )
      expect(result.length).toEqual(1)

    it 'finds expressions beginning with a day', ->
      result = DecorateTime.findDateTimeExpressions(
        'Monday, 19 June from 20:00 - 21:00 UTC'
      )
      expect(result.length).toEqual(1)

    it 'does not find expressions without UTC', ->
      result = DecorateTime.findDateTimeExpressions(
        '19 June from 20:00 - 21:00'
      )
      expect(result).toEqual([])

    it 'ignores case', ->
      result = DecorateTime.findDateTimeExpressions(
        '19 june at 20:00 UTC'
      )
      expect(result.length).toEqual(1)

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
        @sample = '19 June at 20:00 UTC'
        @result = DecorateTime.findDateTimeExpressions(@sample)

      it 'sets the text property to the full match', ->
        expect(@result[0].text).toEqual(@sample)

      it 'sets the year to the current year if not given', ->
        expect(@result[0].utc.year).toEqual('2012')

      it 'sets the year to the one in the string, if given', ->
        result = DecorateTime.findDateTimeExpressions('19 June 2011 at 20:00 UTC')
        expect(result[0].utc.year).toEqual('2011')

      it 'sets the month', ->
        expect(@result[0].utc.month).toEqual('June')

      it 'sets the date', ->
        expect(@result[0].utc.date).toEqual('19')

      it 'sets the start hour', ->
        expect(@result[0].utc.start).toEqual('20:00')

      it 'sets the end hour', ->
        rangeSample = '19 June from 20:00 - 21:00 UTC'
        result = DecorateTime.findDateTimeExpressions(rangeSample)

        expect(result[0].utc.end).toEqual('21:00')

      it 'sets the offset', ->
        rangeSample = '19 June from 20:00 - 21:00 UTC'
        result = DecorateTime.findDateTimeExpressions(rangeSample)

        expect(result[0].local.offset.match(/UTC([-+])?\d+/)).toBeTruthy()

  describe 'eachIn', ->
    beforeEach ->
      $('#testArea').empty()
      $('body').append(
        '<div style="display: none" id="testArea">'
      )
      $('#testArea').append(
        """
        <p>Hello there June 19 from 20:00 - 21:00 UTC.
        Again, it is June 19 from 20:00 - 21:00 UTC.
        Please, June 19 from 20:00 - 21:00 UTC!</p>
        """
      )
      $('#testArea').append(
        """
        <p>August 3rd at 22:00 UTC is the first thing here.
        Also, consider June 19 from 20:00 - 21:00 UTC</p>
        """
      )

    it 'replaces the text with the value in the callback', ->
      DecorateTime.eachIn($('#testArea p'), (dateTime) ->
        "BRENT VATNE"
      )

      firstP = $('#testArea p').first().html()
      lastP  = $('#testArea p').last().html()

      expect(firstP.match(/BRENT VATNE/)).toBeTruthy()
      expect(lastP.match(/BRENT VATNE/)).toBeTruthy()

    describe 'like in the README', ->
      beforeEach ->
        DecorateTime.eachIn $('p'), (dateTime) ->
          start = dateTime.startDate.toString()
          end   = dateTime.endDate.toString()

          "<span>#{dateTime.text}</span>"

      it 'works like it says in the README', ->
        paragraph = $('#testArea p').first().html()
        expect(paragraph.match('span')).toBeTruthy()

      it 'replaces multiple occurrences in a single element', ->
        paragraph = $('#testArea p').first().html()
        expect(paragraph.match(/<span>June 19.*?<\/span>/g).length).toEqual(3)

      it 'does not apply the function to an element more than once', ->
        paragraph = $('#testArea p').first().html()
        expect(paragraph.match(/<span><span>/g)).toBeFalsy()

      it 'replaces multiple occurrences of the same date time in the single element', ->
        paragraph = $('#testArea p').last().html()
        expect(paragraph.match(/<span>.*?<\/span>/g).length).toEqual(2)
