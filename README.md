# Usage

Make sure Ruby (around 2.4.0) is installed.
```
gem install json
```

For example, to get a quote from a profile:
```
ruby print_quote.rb data/Rectangle.json
```

To run the unit tests:
```
ruby test_quote.rb
```

# Comments

- Finding the best rotation to minimize the area of a bounding rectangle seems to be hard in general.  Brief research suggests that an efficient approach would be to approximate each arc with a series of line segments, take the convex hull, and then use a "rotating calipers" approach.  But to keep the code simple, and the running time more predictable, I just tried every rotation in increments of 3 degrees and took the best one.

- There is a bunch of repeated computation, so a little caching would make it more efficient.
