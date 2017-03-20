CC ?= gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

GIT_HOOKS := .git/hooks/applied

EXEC = naive_transpose sse_transpose sse_prefetch_transpose

all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

SRCS_common = main.c

naive_transpose: $(SRCS_common)
	$(CC) $(CFLAGS) -DNAIVE -o $@ $(SRCS_common)

sse_transpose: $(SRCS_common)
	$(CC) $(CFLAGS) -DSSE -o $@ $(SRCS_common)

sse_prefetch_transpose: $(SRCS_common)
	$(CC) $(CFLAGS) -DSSE_PREFETCH -o $@ $(SRCS_common)

cache-test: $(EXEC)
	perf stat --repeat 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses ./naive_transpose
	perf stat --repeat 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses ./sse_transpose
	perf stat --repeat 100 -e cache-misses,cache-references,L1-dcache-load-misses,L1-dcache-loads,L1-dcache-stores,L1-icache-load-misses ./sse_prefetch_transpose

astyle:
	astyle --style=kr --indent=spaces=4 --indent-switches --suffix=none *.[ch]

clean:
	$(RM) main
	$(RM) main $(EXEC)
