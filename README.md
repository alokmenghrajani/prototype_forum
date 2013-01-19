Prototype Forum Tool
--------------------
The prototype forum tool is a tool used at Facebook to run the
post-hackathon presentations. It's an opportunity for engineers to
demo their work in front of the entire company.


This tool has been useful in many ways:
- keeping track of people's ideas in a structured way (i.e. it's a CMS)
- a simple way to run the presentations across our multiple different office locations


This tool was started as an open source project. It's written in Opa (http://www.opalang.org/).
I decided to keep the source open for the following reasons:
- things were self-contained with little dependencies on existing infrastructure,
- the Opa framework is still young and I needed a way to debug things with
  the Opa team.
- I knew this was going to be a significant chunk of Opa code and it might
  be helpful for the Opa community to have access to the code.
- It might be useful to other people who are organizing hackathons.


Note
----
The code we use internally is slightly different from the code in this repo.
I did not handle the fork in a very clean way, and it's most likely some things broke.


License
-------
The Prototype Forum Tool is distribtued under the AGPL license.

Happy coding!
Alok
