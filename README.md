# NSNotificationCenter-Block
A NSNotificationCenter Category to utilize block for Objective-C

## Usage
Using this api is exactly the same as using native api exposed in NSNotificationCenter:

```
[[NSNotificationCenter defaultCenter] addBlockObserver:^(NSNotification *notification) {
        //do your stuff
    } name:UIApplicationDidEnterBackgroundNotification object:nil autoRemove:YES];
```
Here `name`,`object` function as param in `-[NSNotificationCenter addObserver:selector:name:object:]`
the block will be removed automatically if `autoRemove` set to `YES`.
