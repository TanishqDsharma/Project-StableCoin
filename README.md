#  NOTE ABOUT: fail_on_revert 

The pro of `fail_on_revert` equals `false` is that we can very quickly write open testing functions. And we can very quickly write minimal handler functions. The downside is its actually hard to tell all the calls that being made makes any sense.

And when we say `fail_on_revert` equals `true` it ensures that if this test passes that means all the transactions actually went through and it didn't make any dumb calls. The downside of this is that you can make your handler to specific that you might miss the edgecase that might break the systme.