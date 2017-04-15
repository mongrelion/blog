+++
title = "Javascript events pool"
date = "2013-08-22T00:00:00+00:00"
description = "Developing your own EventsPool is easy"
tags = ["javascript", "js"]
+++

If you've lately worked with mainstream SPA frameworks ([Angularjs], [Emberjs], [Backbonejs])
and related, you should know by now that things are kept in sync thanks to data binding.  
It's a pleasure because (with some luck) you just need to setup your bindings and views
and data models would automatically be kept in sync.  
Now, if you are working with a simpler application (that may not require any framework)
but you would like to have some binding still you don't want to load any framework
to your project just because you want some binding here and maybe there.  
In Javascript you can right your own events pool and I will show you how to write it.

The idea is that we can create a list of callbacks under certain namespace that,
at some point, each of them are going to be called.

Let's then create an object, say, `EventsPool`, that will contain a property called
`events`, which is going to be the one that's going to hold all the callbacks
that are going to be called under any given *namespace*

```javascript
var EventsPool    = {};
EventsPool.events = {};
```

Now, let's create a method that will append our callback to a list of callbacks
organized under a given namespace.

```javascript
EventsPool.on = function(event, callback, context) {
  if (!event || typeof(event) !== 'string') {
    throw new Error('Invalid event to listen to.');
  }

  if (!callback || typeof(callback) !== 'function') {
    throw new Error('Invalid callback.');
  }

  context || (context = EventsPool);
  EventsPool.events[event] || (EventsPool.events[event] = []);
  EventsPool.events[event].push({
    callback : callback,
    context  : context
  });

  return EventsPool;
};
```

First we need to make sure that the given `event` is a valid string to avoid
dodgy event names and that there is a `callback` given and that that callback is
actually a function.

```javascript
if (!event || typeof(event) !== 'string') {
  throw new Error('Invalid event to listen to.');
}

if (!callback || typeof(callback) !== 'function') {
  throw new Error('Invalid callback.');
}
```

Then, we're going to make sure that if there is no `context` given, we're going to
use the EventsPool object's context by default. The given `callback` is going
to be called and the `context` variable is going to be send as an argument via
the function.call method (a common use case is that you may want to reference an
instance and refer to it with the `this` keyword).
```javascript
context || (context = EventsPool);
```

We also need to initialize (if it is not already set) the array of callbacks that
are going to be kept under the given namespace via the **event** argument:
```javascript
EventsPool.events[event] || (EventsPool.events[event] = []);
```

We're going to push a JSON object containing both the callback and the
context that is going to be sent to the callback once it's called:
```javascript
EventsPool.events[event].push({
  callback : callback,
  context  : context
});
```

Finally, we return the EventsPool object to allow method chaining:
```javascript
return EventsPool;
```

Let's test this code on [Nodejs]'s console (NOTE: I've slightly changed the code
so that [Nodejs]'s console can 
```javascript
> require('./events_pool');
{}
> EventsPool
{ events: {}, on: [Function] }
> EventsPool.on('lights:off', function() {
    return console.log('Going to sleep!');
  });
undefined
> EventsPool.events
{ 'lights:off': [ { callback: [Function], context: [Object] } ] }
```

We can go ahead and directly call that one callback that we registered under the
`lights:off` namespace:
```javascript
> EventsPool.events['lights:off'][0].callback();
Going to sleep!
// Or using the context for it:
> var callback = EventsPool.events['lights:off'][0]
```

But calling it manually is kinda lame so let's write a function that loops over
the registered callbacks for a given namespace and call them using their callbacks.

```javascript
EventsPool.emit = function(event) {
  if (!event || typeof(event) !== 'string') {
    throw new Error('Invalid event');
  }

  var events = this.events[event];
  if (events instanceof Array) {
    events.forEach(function(e) {
      e.callback.call(e.context);
    });
  }
};
```

Again, we fist want to make sure that the given event is given and that it's a string:
```javascript
if (!event || typeof(event) !== 'string') {
  throw new Error('Invalid event');
}
```

Then, we retrieve the callbacks registered under that namespace/event name and
iterate over them (if any!) and call them via the Function.call method, sending
the event's setup context as an argument.
```javascript
if (events instanceof Array) {
  events.forEach(function(e) {
    e.callback.call(e.context);
  });
}
```

That's it. Let's try it out!
```javascript
> require('./events_pool')
{}
> EventsPool
{
  events : {},
  on     : [Function],
  emit   : [Function]
}
> EventsPool.on('lights:off', function() { console.log('Going to sleep!'); });
{
  events : {
    'lights:off' : [ [Object] ]
  },
  on   : [Function],
  emit : [Function]
}
> EventsPool.emit('lights:off');
Going to sleep!
undefined
// And testing the context object:
var user = { nick : 'mongrelion' };
> EventsPool.on('lights:on', function() {
    console.log("%s says: I'm trying to sleep!", this.nick);
  }, user);
{
  events : {
    'lights:on'  : [ [Object] ],
    'lights:off' : [ [Object] ]
  },
  on   : [Function],
  emit : [Function]
}
> EventsPool.emit('lights:on');
mongrelion is trying to sleep!
undefined
```

There you have it.

[Angularjs]: http://angularjs.org
[Emberjs]: http://emberjs.com
[Backbonejs]: http://documentcloud.github.io/backbone
[Nodejs]: http://nodejs.org
