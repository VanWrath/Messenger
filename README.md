# Messenger

## 1 Introduction  
Management has decided to develop a messaging system for use in hospitals. Physicians,
nurses, and administrators shall be able to securely use it for communication. Users can be
subscribed to groups and can send a message to the group. It is essential for privacy
concerns that only those users registered in a group may read messages directed at the group.
This is mission critical application  
* in the sense that you must design the software system to guarantee patient privacy;  
* You must also implement and document your design to show that your design is correct and satisfies the specified safety behavior;  
* You validate the safety of your system using contracts, unit tests and acceptance tests.

## 2 Requirements  
  Requirements elicitation has resulted in an abstract grammar for the user interface.
Eventually, there will be a desktop application, a webapp and mobile app for users
(physicians, nurses, administrators and patients). However, the concrete GUIs will be
developed at a later stage and are beyond the scope of this project. The concrete GUIs will
support all the operations in the abstract grammar.  

  Also, one Use Case has been developed so far. This Use Case has been refined into an
Acceptance test called at1.txt.  

  When an operation can be performed, the system responds with “ok”. However, when
some operation cannot be performed, the acceptance test currently responds with a
meaningful error message. You are required to perform further requirements elicitation to
obtain the precise error messages.  

  Instead of a complete specification, you are also provided with an Oracle. You will thus
need to develop your own additional acceptance test at2.txt, at3.txt etc. It is interesting to
note that these acceptance test (being structured text files) are independent of the
programming language used to develop the system. These acceptance tests can thus be
written by users who are not familiar with programming. Such acceptance tests can thus be
developed before the system is ever implemented. A good set of acceptance tests is thus part
of the eHealth specification.

Code can be found in "messenger-project/messenger/model" directory. Eveything else is generated by the Effel Testing Framework(ETF).
