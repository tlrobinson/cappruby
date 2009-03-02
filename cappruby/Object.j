@import <Foundation/CPObject.j>

// FIXME: is this safe?
//Object.isa = CPObject;

@implementation CPObject (Ruby)

+ (CPArray)ancestors
{
    var ancestors = [],
        klass = self;   
    while (klass)
    {
        ancestors.push(klass);
        klass = klass.super_class;
    }
    return ancestors;
}

@end