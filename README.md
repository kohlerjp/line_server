# LineServer

### How does your system work?
This is an elixir program running on the Phoenix web framework. Phoenix handles the incoming API requests, and responds
with the JSON response. 
The system is comprised of two main parts. The first is the module `LineServer.LineParser`. This is a process that is kicked off
on startup. The parser breaks down the file into a series of blocks, each block's size is equal to the square root of the
total file size. Each text block is then scanned to determine how many lines appear within that block. Each block and it's line count
are used as indexes and are kept in a linked list. To use an example, imagine a file that is 25 bytes in size, and every 5 bytes
of the file contains 8 lines. The resulting indexes are stored as a linked list, where each node contains the block number, and
the amount of lines seen up to that point. The resulting list would appear as: 
```
[{0, 8}, {1, 16}, {2, 24}, {3, 32}, {4, 40}]
```

These indexes are then stored in a separate process called an Agent.

An Agent is an Elixir process that is capable of storing state. The module `LineServer.LineAgent` is the second part of the system,
and is responsible for storing the indexes, and retrieving the desired line. When a request comes in, the agent is able to use
the indexes to determine where in the file it must look. Using the example from above, let's say we wanted to find the 30th line.
Using the indexes, we see that block 3 is the first node with a number count higher than 30. This means the 30th line must be 
inside that block. Block size is 5 bytes, so we will start looking at the 15th byte. It is possible for a line to be spread across 
separate blocks, in those scenarios, we can use the line counts to determine the maximum amount of space we need to read. Once the
location and read distance are found, we can perform a read and count to the requested line.

On my first iteration of the project, I was using a percentage of the file for block size rather than the square root. I liked this solution since it would allow for a constant amount of memory to be used when storing the indexes, and each block's
read time would only be a small percent of the total size. Of course, the block scan time would still grow linearly with this size of the file. I figured this wouldn't be a big deal since I would use a very small percent, and I could always tweak the configuration. Unfortunately, the scan
time grew too fast as the files grew larger. 

I then decided to sacrafice some memory in return for faster lookups. By using the square root of the file size, we could ensure the
average scan time grew at a rate slower than linear. This remains true only for the average case, if a single file consists of a single line,
the entire file will still need to be scanned. It also has the benefit of taking up only O(sqrt(n)) in terms of memory.

Naturally, this led to the third option, of keeping a fixed scan space. But this would lead to a linear increase in memory, and would
become unreasonable quickly for large files.

### How will your system perform with a 1 GB file? a 10 GB file? a 100 GB file?
Most of the computing time is spent on startup, where a linear scan through the file is performed and indexes are created. Although it
does get a bit slower with file increase, this is much preferable to an increase in lookup time, which would have a much higher impact on users.  Since (average) lookup time and memory usage are a function of the square root of the file size, these increase much slower. Doing
some very rough calculations, the program was able to lookup a line in a 1.7GB (block size 41231 bytes) file in 3.6 ms, 
or .00008 ms/byte. A 100GB file would have a block size of 316227 bytes, so the line could be found in roughly 25 milliseconds. 
The inital linear scan through the file however, would take a very long time.

### How will your system perform with 100 users? 10000 users? 1000000 users?
The Agent processes are not known to do very well with concurrency. Since it is a single process, it can only perform one lookup at 
a time. Since the lookup time is rather quick, this shouldn't be too much of a problem, but steps could be taken to allow for better
concurrency. We could use an ETS table for storing the indexes. This is an in-memory data table which allows for quick
concurrent reads. We could also explore options to read the file in separate concurrent processes, as it is read-only.

### What documentation, websites, papers, etc did you consult in doing this assignment?
- Elixir documentation: https://hexdocs.pm/elixir/Kernel.html
- Phoenix documentation: https://hexdocs.pm/phoenix/Phoenix.html
- Erlang file documentation: http://erlang.org/doc/man/file.html


### What third-party libraries or other tools does the system use? How did you choose each library or framework you used?
I decided to use Elixir and the Phoenix web framework for this project. Elixir is a great language for writing functional
code, and is typically great for concurrency and robust systems. I chose Phoenix because I am very familiar with it, although
it may have been heavier than what was needed for this project. A light-weight REST framework
like [maru](https://github.com/elixir-maru/maru) would have worked fine as well.

### How long did you spend on this exercise? If you had unlimited more time to spend on this, how would you spend it and how would you prioritize each item?

I spent roughly 5 hours on the exercise. If I had unlimited time, the first thing I would do is strive for complete test coverage. There are a few unit tests, but the project would benefit from more integration tests. I would then work on allowing for better concurrency. As stated above, an
ETS table and multiple file reading processes may allow for more concurrent users. I would also like to spend more time on the index data structure I chose. A linked list was my first thought because the lookup reminded me of how a set is implemented. I would like to reasearch more data structures used by databases, and see if that could be beneficial in terms of memory or lookup time.

### If you were to critique your code, what would you have to say about it?
My first critique would be of the data structure holding the indexes. The additive nature of the line counts could be confusing,
and there isn't much of a reason for them to behave that way. Each node depends on the previous node, this prevents the structure
from being created concurrently, which could potentially speed up initialization time. We would have access to the same information
if each node only contained the amount of lines seen in that block.

Error handling is also lacking. The program always assumes the file exists, and it will blow up otherwise. These scenarios can
be handled easily with the elixir `with` clause.

A few 'magic numbers' appear in the code, it would be more readable if these had variable names or explanations.
