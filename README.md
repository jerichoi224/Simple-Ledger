
<h1 align="center">
  <img src="https://github.com/jerichoi224/Simple-Ledger/blob/master/media/cover.jpeg">
</h1>

A Simple Ledger App, sibling to the Money Tracker (Its almost a clone as of v.1.0.0) But, Hoping to add a bit more here and there. I initially thought of buildling the Money Tracker and Simple Ledger in one app, but realized they take a different approach in tracking money, and having them in one app didn't quite make sense. I think it was a good idea, as I found some problems I should fix in money tracker while rewriting the code from scratch.


## Basic Overview
Its a simple Ledger. You Spend/Save Money. You can add subscriptions if you want which will automatically create an entry either monthly or yearly. Currently Supports USD and KRW, but I can probably easily add more. I do plan to add more system languages as well.

### Basic Functionality
<img src="https://github.com/jerichoi224/Simple-Ledger/blob/master/media/screenshots1.jpeg">

The three screenshots above show the basic functionality of the app. You Record your spendings, on the left. You can see how much you have left in the middle, and see all your previous spendings on the right


### More Functionalities
<img src="https://github.com/jerichoi224/Simple-Ledger/blob/master/media/screenshots2.jpeg">

I do have the one-time intro implemented, I just don't know what to put it so its disabled for now.

The Setting Menu lets you change the system UI, and manage subscriptions Changing to show the entire history will show all spendings in a infinitely growing list instead of showing it day by day.

The Subscription management lets you register subscription payments for monthly or yearly payments. On the day of payment, a spending entry will be automatically created.

### Open Source!

This app, while it was built for my own use, I ended up learning alot on how to build apps using Flutter, or at least alot of the basic functionalities (no fancy libraries or APIs or network use). And I think this would give help on people learning Flutter. I use alot of the basic functionalities that are crucial in many apps including, but not limited to saving/loading data to shared preferences and database, using splashscreens, scroll view layout, non-scroll view navigation, etc. Hopefully this is useful for whoever ends up here!