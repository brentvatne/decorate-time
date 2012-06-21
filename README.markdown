DecorateTime
=============

Made this a Rails app just to get a quick CoffeeScript/Jasmine testing
workflow. This is a JavaScript library that will find strings like 'June
19 at 20:00 UTC' within large blocks of text and then allow you replace
them with something, such as the users local time, or perhaps a span
with a data-attribute that will let you create a hover effect that
presents the users local time.

```coffeescript
  DecorateTime.eachIn $('p'), (data) ->
    start = data.startDate.toString()
    end   = data.endDate.toString()

    "<span class='date-time' data-start='#{start}' data-end='#{end}'>#{dateTime.text}</span>"
```

To run the specs, just do `rails s` and navigate to http://localhost:3000/jasmin
