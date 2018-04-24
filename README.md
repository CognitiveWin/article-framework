# Framework Thinking

This is an article about frameworks, but more importantly it intends to describe an initial step towards thinking in frameworks and applying this thinking when writing code and architecting solutions.

But before things get technical, it’s worth considering the more abstract notion of frameworks. Take the Collins English Dictionary definition:

    A framework is a particular set of rules, ideas, or beliefs which you use in order to deal with problems or to decide what to do.

Frameworks can be found anywhere were complexity needs to be managed. Wikipedia’s page on Scrum begins:

    Scrum is an agile framework for managing work with an emphasis on software development.

There is no formal definition of a framework or, it’s counterpart, the library and as a result there is discourse and debate. This article will use some broad (loose?) definitions to make sense of things.

## A library:

is a mechanism allowing code to be shared in some form. This can be code or binary.
Is usually configurable, but not necessarily extensible.
it is acted upon by a client with control returning to the client after each call.

## A framework:

provides a skeletal implementation.
manages control flow and that of its client.
offers extensibility through inversion of control.

Where things get gray is that the mechanism of a library can deliver a framework and “frameworks” in iOS can just be libraries.

# UITableView

A pivotal aspect of iOS development, and one familiar to most iOS developers, is the `UITableView` and its two delegate protocols; `UITableViewDataSource` and `UITableViewDelegate`.

`UITableView` is often the centerpiece of many apps but over several iterations of iOS its core interface has remained the same. For this reason it’s fair to say that it’s design was a success.

Much of `UITableView`’s usage lies with just two required methods defined by the `UITableViewDataSourceDelegate` protocol:

    `func tableView(UITableView, cellForRowAt: IndexPath)` asks the data source for a cell to insert in a particular location of the table view.
    `func numberOfSections(in: UITableView)` tells the data source to return the number of rows in a given section of a table view

The language, taken from Apple’s documentation, is telling. The first method *asks* the client, the data source for a cell, and also *tells* the data source to return the number of rows. Control of flow is clearly with the UITableView.

`UITableView`’s implementation details are hidden, including its exceptional performance, yet it is extensible by the client.

(Mike Ash has an excellent pos in which he breaks down the underlying implementation from his own observations.)
Demonstration

To demonstrate the use of frameworks this example take a simple algorithm classifying a password into poor, weak, good and strong.

A naive approach is based on the length and content of the password. This is inspired by a jQuery library, pStrength, and is further simplified.

The rules for this password are:

1. Two points for at least ten characters
2. Two points for at least two lowercase characters
3. Two points for at least two uppercase characters
4. Two points for at least two digits
5. Two points for at least two symbols

Two points for each aspect means the maximum password must be ten characters long and have two of lowercase, uppercase, digits and symbols, giving a total of ten points.

These ten points will map to classified strengths:

- [0, 2) None (or, too bad for words)
- [2, 4) Weak
- [6, 8) Good
- [8, 10) Strong

A library implementation of this could be simple, and is ruthlessly coded to demonstrate this.

```final class PasswordStrength {

  class func getStrength(password: String) -> Strength {
    // Implementation
  }
}```

This could really be an extension of String, it’s so simple.

But what does this mean for out client code?

1. A UITextField captures the entered password.
2. getStrength is called with the password
3. The returned strength is used in the UI.

And how about some basic UX?

A red, orange, yellow green bar is used to give feedback on the changing strength of the password to the user.
When the strength of the password meets some criteria the user will be alerted.

To implement these the UI or model will have to manage a before value and an after value to detect change in strength. It will also have to check that the strength has exceeded a threshold.

The framework version looks a little different.

A protocol is defined the client must implement to make best use of the framework.

```protocol PasswordStrengthDelegate: class {
    
    func didMatchReservedWord()
    func didChangeStrength(_ strength: Strength)
    func didMeetMinimumStrength()
    func minimumStrengthForPassword() -> Strength
}```

```class PasswordStrength {
    
    weak var delegate: PasswordStrengthDelegate?
    var reservedWords: [String] = [] // Talk about this
    var password: String?
    
    private(set) var strength: Strength = .none
}```

What benefits does this provide the client?

- The client does not have to track changes of the strength of the password. It will receive a delegate callback or event.
- The client does not have to track when a threshold has been reached.
- The client remains in control of what the minimum password strength.

Further:

- As far as frameworks go this has not been restricted to any specific UX implementation..
- A custom wrapper for consistency of use in different scenarios is not required.
- Any performance optimizations can be made to the framework without affecting the client.
- It’s unlikely that any algorithm implementation changes will affect the defined interface.

You’ll notice a reserved words array exposed to the client. This is the list of reserved words to check against so we can exclude popular passwords like “password” and “qwerty”. Each time the password is set it is compared against reserved words and if there is a match didMatchReservedWord will be called.

But what could go wrong with this?

- A reserved words list is unlikely to change during the course of a password entry session, but this allows the property to be set whenever the client chooses to. This could end up being inconsistent.
- PasswordStrength may elect to optimise the lookup of reserved words using an alternative data structure. If this takes some amount of time to parse the performance could suffer.

A framework solution to this approach is to have the framework request this list using a delegate method and do this only once.

# A note on Clean Architecture and VIPER

Clean Architecture (from Dr Bob Martin) is a concentric, layered approach to software architecture drawing on several other sources. The VIPER pattern (View, Interactor, Presenter, Entity and Router) is an iOS-specific variant of Clean Architecture.

A prevailing philosophy with Clean Architecture is the Dependency Rule:

    dependencies points inward

Inner circles cannot know anything about outer circles. And this is the same approach used with framework thinking.

Sources

[Investion of Control](https://en.wikipedia.org/wiki/Inversion_of_control)
[The Clean Architecture](https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html)
[Scrum Guides](http://www.scrumguides.org)
[Injection](https://martinfowler.com/articles/injection.html)
[Let's Build UITableView](https://www.mikeash.com/pyblog/friday-qa-2013-02-22-lets-build-uitableview.html)
[Scum (software development)](https://en.wikipedia.org/wiki/Scrum_(software_development))
[Framework](https://www.collinsdictionary.com/dictionary/english/framework)
[UITableViewDataSource](https://developer.apple.com/documentation/uikit/uitableviewdatasource)

