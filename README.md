# Usage

Make sure Ruby (around 2.4.0) is installed.
```
gem install json
```

For example, to get a quote from a profile:
```
ruby print_quote.rb Rectangle.json
```

To run the unit tests:
```
ruby test_quote.rb
```

# Improvements
There is a bunch of repeated computation, so a little caching would make it more efficient.
