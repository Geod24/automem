module ut.issues;


import ut;
import automem;


private typeof(vector(1).range()) gVectorIntRange;

version(AutomemAsan) {}
else {

    @ShouldFail("https://issues.dlang.org/show_bug.cgi?id=19752")
    @("26")
    @safe unittest {
        static void escape() {
            auto vec = vector(1, 2, 3);
            gVectorIntRange = vec.range;
        }

        static void stackSmash() {
            long[4096] arr = 42;
        }

        escape;
        gVectorIntRange.length.should == 0;
        stackSmash;
        gVectorIntRange.length.should == 0;
    }
}


@("27")
@safe unittest {
    const str = String("foobar");

    (str == "foobar").should == true;
    (str == "barfoo").should == false;
    (str == "quux").should == false;

    (str == String("foobar")).should == true;
    (str == String("barfoo")).should == false;
    (str == String("quux")).should == false;
}


@("37")
@safe unittest {

    static struct S {
        int front;
        void popFront() { ++front; }
        @property bool empty() { return front >= 10; }
    }

    auto rc = RefCounted!S(0);
    foreach(i; *rc) {}

    auto un = Unique!S(0);
    foreach(i; *un) {}
}


@("38")
@safe unittest {

    import core.exception: AssertError;

    static struct S {
        int front = 0;
    }

    auto rc = RefCounted!S();
    rc.front.shouldThrow!AssertError;
}


version(unitThreadedLight) {}
else {
    @HiddenTest
    @("51")
    @system unittest {

        import std.experimental.allocator: allocatorObject;
        import std.experimental.allocator.mallocator: Mallocator;

        static interface Interface {
            void hello();
            string test();
        }

        static class Oops: Interface {
            private ubyte[] _buffer;
            override void hello() {}
            override string test() { return "foo"; }
            this() { _buffer.length = 1024 * 1024; }
            ~this() {}

            static Oops opCall() {
                import std.experimental.allocator: theAllocator, make;
                return theAllocator.make!Oops;
            }
        }

        Vector!Interface interfaces;
        foreach(i; 0 .. 12) interfaces ~= Oops();
    }
}
