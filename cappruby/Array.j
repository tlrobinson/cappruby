@import <Foundation/CPArray.j>

@implementation CPArray (Ruby)

- (CPArray)map
{
    var _rbYield=window._rbBlock||window._rbNoBlock; // FIXME: how? needed in Obj-J method defs that use yield.
    
    var result = [];
    for (var i = 0; i < self.length; i++)
        result.push(_rbYield(self[i]));
    return result;
}

- (void)each
{
    [self map];
}

@end
