#= require decorate_time

paragraph = """
            Please join us on June 19 from 20:00 - 21:00 UTC for a group discussion on
            how to best keep database wrapping and domain logic separated in different
            objects. The next one will be August 20 from 19:00 - 20:00 UTC, remember!
            """

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
      result = DecorateTime.findDateTimeExpressions(paragraph)
      expect(result.length).toEqual(2)

    describe 'result object', ->
      beforeEach ->
        @rangeSample = '19 June from 20:00 - 21:00 UTC'
        @sample      = '19 June at 20:00 UTC'
        @result      = DecorateTime.findDateTimeExpressions(@sample)

      it 'sets the text property to the full match', ->
        expect(@result[0].text).toEqual(@sample)

      it 'sets the year to the current year if not given', ->
        expect(@result[0].year).toEqual('2012')

      it 'sets the year to the one in the string, if given', ->
        result = DecorateTime.findDateTimeExpressions('19 June 2011 at 20:00 UTC')
        expect(result[0].year).toEqual('2011')



