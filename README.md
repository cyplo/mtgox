# Ruby wrapper for the Mt. Gox Trade API
Mt. Gox allows you to trade multiple currencies for Bitcoins (BTC) or vice versa.

[pirapira]: http://github.com/pirapira/mtgox
[travis]: http://travis-ci.org/sferik/mtgox
[gemnasium]: https://gemnasium.com/sferik/mtgox

## Installation


## Alias
After installing the gem, you can get the current price for 1 BTC in USD by
typing `btc` in your bash shell simply by setting the following alias:

    alias btc='ruby -r rubygems -r mtgox -e "puts MtGox.ticker.sell"'

## Documentation

## Usage Examples
    require 'rubygems'
    require 'mtgox'

    # Fetch the latest price for 1 BTC in USD
    puts MtGox.ticker("USD").sell

    # Fetch open asks
    puts MtGox.asks("USD")

    # Fetch open bids
    puts MtGox.bids("USD")

    # Fetch the last 48 hours worth of trades (takes a minute)
    puts MtGox.trades("USD")

    # Certain methods require authentication
    MtGox.configure do |config|
      config.key = YOUR_MTGOX_KEY
      config.secret = YOUR_MTGOX_SECRET
    end

    # Fetch your current balance
    puts MtGox.balance

    # Place a limit order to buy one bitcoin for $0.011
    MtGox.buy! 1.0, 0.011, "USD"

    # Place a limit order to sell one bitcoin for $100
    MtGox.sell! 1.0, 100.0, "USD"

    # Fetch your open orders
    MtGox.orders

    # Cancel order #1234567890
    MtGox.cancel 1234567890

    # Withdraw 1 BTC from your account
    MtGox.withdraw! 1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"

## Contributing
In the spirit of [free software][free-sw], **everyone** is encouraged to help
improve this project.

[free-sw]: http://www.fsf.org/licensing/essays/free-sw.html

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up
  inconsistent whitespace)
* by refactoring code
* by closing [issues][]
* by reviewing patches

[issues]: https://github.com/sferik/mtgox/issues

## Submitting an Issue
We use the [GitHub issue tracker][issues] to track bugs and features. Before
submitting a bug report or feature request, check to make sure it hasn't
already been submitted. When submitting a bug report, please include a [Gist][]
that includes a stack trace and any details that may be necessary to reproduce
the bug, including your gem version, Ruby version, and operating system.
Ideally, a bug report should include a pull request with failing specs.

[gist]: https://gist.github.com/

## Submitting a Pull Request
1. [Fork the repository.][fork]
2. [Create a topic branch.][branch]
3. Add specs for your unimplemented feature or bug fix.
4. Run `bundle exec rake spec`. If your specs pass, return to step 3.
5. Implement your feature or bug fix.
6. Run `bundle exec rake spec`. If your specs fail, return to step 5.
7. Run `open coverage/index.html`. If your changes are not completely covered
   by your tests, return to step 3.
8. Add documentation for your feature or bug fix.
9. Run `bundle exec rake doc:yard`. If your changes are not 100% documented, go
   back to step 8.
10. Add, commit, and push your changes.
11. [Submit a pull request.][pr]

[fork]: http://help.github.com/fork-a-repo/
[branch]: http://learn.github.com/p/branching.html
[pr]: http://help.github.com/send-pull-requests/

## Supported Ruby Versions
This library aims to support and is [tested against][travis] the following Ruby
implementations:

* Ruby 1.9.2
* Ruby 1.9.3

If something doesn't work on one of these interpreters, it should be considered
a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be personally responsible for providing patches in a
timely fashion. If critical issues for a particular implementation exist at the
time of a major release, support for that Ruby version may be dropped.

## Copyright
Copyright (c) 2012 Yoichi Hirai
Copyright (c) 2011 Erik Michaels-Ober. See [LICENSE][] for details.

[license]: https://github.com/pirapira/mtgox/blob/master/LICENSE.md
