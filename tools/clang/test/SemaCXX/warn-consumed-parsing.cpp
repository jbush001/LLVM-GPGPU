// RUN: %clang_cc1 -fsyntax-only -verify -Wconsumed -std=c++11 %s

#define CALLABLE_WHEN(...)      __attribute__ ((callable_when(__VA_ARGS__)))
#define CONSUMABLE(state)       __attribute__ ((consumable(state)))
#define SET_TYPESTATE(state)    __attribute__ ((set_typestate(state)))
#define RETURN_TYPESTATE(state) __attribute__ ((return_typestate(state)))
#define TESTS_TYPESTATE(state)  __attribute__ ((tests_typestate(state)))

// FIXME: This test is here because the warning is issued by the Consumed
//        analysis, not SemaDeclAttr.  The analysis won't run after an error
//        has been issued.  Once the attribute propagation for template
//        instantiation has been fixed, this can be moved somewhere else and the
//        definition can be removed.
int returnTypestateForUnconsumable() RETURN_TYPESTATE(consumed); // expected-warning {{return state set for an unconsumable type 'int'}}
int returnTypestateForUnconsumable() {
  return 0;
}

class AttrTester0 {
  void consumes()        __attribute__ ((set_typestate())); // expected-error {{attribute takes one argument}}
  bool testsUnconsumed() __attribute__ ((tests_typestate())); // expected-error {{attribute takes one argument}}
  void callableWhen()    __attribute__ ((callable_when())); // expected-error {{attribute takes at least 1 argument}}
};

int var0 SET_TYPESTATE(consumed); // expected-warning {{'set_typestate' attribute only applies to methods}}
int var1 TESTS_TYPESTATE(consumed); // expected-warning {{'tests_typestate' attribute only applies to methods}}
int var2 CALLABLE_WHEN("consumed"); // expected-warning {{'callable_when' attribute only applies to methods}}
int var3 CONSUMABLE(consumed); // expected-warning {{'consumable' attribute only applies to classes}}
int var4 RETURN_TYPESTATE(consumed); // expected-warning {{'return_typestate' attribute only applies to functions}}

void function0() SET_TYPESTATE(consumed); // expected-warning {{'set_typestate' attribute only applies to methods}}
void function1() TESTS_TYPESTATE(consumed); // expected-warning {{'tests_typestate' attribute only applies to methods}}
void function2() CALLABLE_WHEN("consumed"); // expected-warning {{'callable_when' attribute only applies to methods}}
void function3() CONSUMABLE(consumed); // expected-warning {{'consumable' attribute only applies to classes}}

class CONSUMABLE(unknown) AttrTester1 {
  void callableWhen0()   CALLABLE_WHEN("unconsumed");
  void callableWhen1()   CALLABLE_WHEN(42); // expected-error {{'callable_when' attribute requires a string}}
  void callableWhen2()   CALLABLE_WHEN("foo"); // expected-warning {{'callable_when' attribute argument not supported: foo}}
  void consumes()        SET_TYPESTATE(consumed);
  bool testsUnconsumed() TESTS_TYPESTATE(consumed);
};

AttrTester1 returnTypestateTester0() RETURN_TYPESTATE(not_a_state); // expected-warning {{'return_typestate' attribute argument not supported: 'not_a_state'}}
AttrTester1 returnTypestateTester1() RETURN_TYPESTATE(42); // expected-error {{'return_typestate' attribute requires an identifier}}

class AttrTester2 {
  void callableWhen()    CALLABLE_WHEN("unconsumed"); // expected-warning {{consumed analysis attribute is attached to member of class 'AttrTester2' which isn't marked as consumable}}
  void consumes()        SET_TYPESTATE(consumed); // expected-warning {{consumed analysis attribute is attached to member of class 'AttrTester2' which isn't marked as consumable}}
  bool testsUnconsumed() TESTS_TYPESTATE(consumed); // expected-warning {{consumed analysis attribute is attached to member of class 'AttrTester2' which isn't marked as consumable}}
};

class CONSUMABLE(42) AttrTester3; // expected-error {{'consumable' attribute requires an identifier}}
