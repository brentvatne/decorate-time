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
      expect(result).toBeFalsy()

    it 'it detects date time strings in large blocks of text', ->
      result = DecorateTime.findDateTimeExpressions(paragraph)
      console.log result
      expect(result).toBeTruthy()

