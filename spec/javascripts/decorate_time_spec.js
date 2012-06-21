(function() {

  describe('DecorateTime', function() {
    describe('findDateTimeExpressions', function() {
      describe('incomplete expressions', function() {
        it('finds just times', function() {
          var result;
          result = DecorateTime.findDateTimeExpressions('20:00 UTC');
          return expect(result.length).toEqual(1);
        });
        it('gives the correct start time', function() {
          var result;
          result = DecorateTime.findDateTimeExpressions('20:00 UTC');
          return expect(result[0].utc.start).toEqual('20:00');
        });
        return it('works for ranges too', function() {
          var result;
          result = DecorateTime.findDateTimeExpressions('20:00 - 21:00 UTC');
          expect(result[0].utc.start).toEqual('20:00');
          return expect(result[0].utc.end).toEqual('21:00');
        });
      });
      it('finds expressions beginning with a month', function() {
        var result;
        result = DecorateTime.findDateTimeExpressions('Monday, June 19 from 20:00 - 21:00 UTC');
        return expect(result.length).toEqual(1);
      });
      it('finds expressions beginning with a day', function() {
        var result;
        result = DecorateTime.findDateTimeExpressions('Monday, 19 June from 20:00 - 21:00 UTC');
        return expect(result.length).toEqual(1);
      });
      it('does not find expressions without UTC', function() {
        var result;
        result = DecorateTime.findDateTimeExpressions('19 June from 20:00 - 21:00');
        return expect(result).toEqual([]);
      });
      it('ignores case', function() {
        var result;
        result = DecorateTime.findDateTimeExpressions('19 june at 20:00 UTC');
        return expect(result.length).toEqual(1);
      });
      it('it detects date time strings in large blocks of text', function() {
        var paragraph, result;
        paragraph = "Please join us on June 19 from 20:00 - 21:00 UTC for a group discussion on\nhow to best keep database wrapping and domain logic separated in different\nobjects. The next one will be August 20 from 19:00 - 20:00 UTC, remember!";
        result = DecorateTime.findDateTimeExpressions(paragraph);
        return expect(result.length).toEqual(2);
      });
      return describe('result object', function() {
        beforeEach(function() {
          this.sample = '19 June at 20:00 UTC';
          return this.result = DecorateTime.findDateTimeExpressions(this.sample);
        });
        it('sets the text property to the full match', function() {
          return expect(this.result[0].utc.text).toEqual(this.sample);
        });
        it('sets the year to the current year if not given', function() {
          return expect(this.result[0].utc.year).toEqual('2012');
        });
        it('sets the year to the one in the string, if given', function() {
          var result;
          result = DecorateTime.findDateTimeExpressions('19 June 2011 at 20:00 UTC');
          return expect(result[0].utc.year).toEqual('2011');
        });
        it('sets the month', function() {
          return expect(this.result[0].utc.month).toEqual('June');
        });
        it('sets the date', function() {
          return expect(this.result[0].utc.date).toEqual('19');
        });
        it('sets the start hour', function() {
          return expect(this.result[0].utc.start).toEqual('20:00');
        });
        it('sets the end hour', function() {
          var rangeSample, result;
          rangeSample = '19 June from 20:00 - 21:00 UTC';
          result = DecorateTime.findDateTimeExpressions(rangeSample);
          return expect(result[0].utc.end).toEqual('21:00');
        });
        it('sets the offset', function() {
          var rangeSample, result;
          rangeSample = '19 June from 20:00 - 21:00 UTC';
          result = DecorateTime.findDateTimeExpressions(rangeSample);
          return expect(result[0].local.offset.match(/UTC([-+])?\d+/)).toBeTruthy();
        });
        it('keeps the day in the same format', function() {
          return 'pending - Friday should stay as Friday, Fri should be Fri';
        });
        it('keeps the month in the same format', function() {
          return 'pending - see above';
        });
        return describe('local.text', function() {
          beforeEach(function() {
            var rangeSample;
            rangeSample = 'Friday June 1st from 00:00 - 21:00 UTC';
            this.result = DecorateTime.findDateTimeExpressions(rangeSample)[0];
            return this.local = this.result.local;
          });
          it('replaces the day', function() {
            return expect(this.local.text.match(this.local.day)).toBeTruthy();
          });
          it('replaces the date', function() {
            return expect(this.local.text.match(/31st/)).toBeTruthy();
          });
          it('adds the correct suffix to the date', function() {
            var local, rangeSample;
            rangeSample = 'Saturday June 2nd from 00:00 - 21:00 UTC';
            local = DecorateTime.findDateTimeExpressions(rangeSample)[0].local;
            rangeSample = 'Monday June 4th from 00:00 - 21:00 UTC';
            return local = DecorateTime.findDateTimeExpressions(rangeSample)[0].local;
          });
          it('replaces the offset', function() {
            return expect(this.local.text.match(this.local.offset)).toBeTruthy();
          });
          it('replaces the month', function() {
            return expect(this.local.text.match(this.local.month)).toBeTruthy();
          });
          it('replaces the start time', function() {
            return expect(this.local.text.match(this.local.start)).toBeTruthy();
          });
          return it('replaces the end time', function() {
            return expect(this.local.text.match(this.local.end)).toBeTruthy();
          });
        });
      });
    });
    return describe('eachIn', function() {
      beforeEach(function() {
        $('#testArea').empty();
        $('body').append('<div style="display: none" id="testArea">');
        $('#testArea').append("<p>Hello there June 19 from 20:00 - 21:00 UTC.\nAgain, it is June 19 from 20:00 - 21:00 UTC.\nPlease, June 19 from 20:00 - 21:00 UTC!</p>");
        return $('#testArea').append("<p>August 3rd at 22:00 UTC is the first thing here.\nAlso, consider June 19 from 20:00 - 21:00 UTC</p>");
      });
      it('replaces the text with the value in the callback', function() {
        var firstP, lastP;
        DecorateTime.eachIn($('#testArea p'), function(dateTime) {
          return "BRENT VATNE";
        });
        firstP = $('#testArea p').first().html();
        lastP = $('#testArea p').last().html();
        expect(firstP.match(/BRENT VATNE/)).toBeTruthy();
        return expect(lastP.match(/BRENT VATNE/)).toBeTruthy();
      });
      return describe('like in the README', function() {
        beforeEach(function() {
          return DecorateTime.eachIn($('#testArea p'), function(dateTime) {
            return "<span>" + dateTime.utc.text + "</span>";
          });
        });
        it('works like it says in the README', function() {
          var paragraph;
          paragraph = $('#testArea p').first().html();
          return expect(paragraph.match('span')).toBeTruthy();
        });
        it('replaces multiple occurrences in a single element', function() {
          var paragraph;
          paragraph = $('#testArea p').first().html();
          return expect(paragraph.match(/<span>June 19.*?<\/span>/g).length).toEqual(3);
        });
        it('does not apply the function to an element more than once', function() {
          var paragraph;
          paragraph = $('#testArea p').first().html();
          return expect(paragraph.match(/<span><span>/g)).toBeFalsy();
        });
        return it('replaces multiple occurrences of the same date time in the single element', function() {
          var paragraph;
          paragraph = $('#testArea p').last().html();
          return expect(paragraph.match(/<span>.*?<\/span>/g).length).toEqual(2);
        });
      });
    });
  });

}).call(this);
