# OSX Makefile

build=build
target=$(build)/devops-detective-agency

CXXFLAGS=\
-Wall \
-g \
-pg \
-Imruby/include \
-Ilibyaml/include

CFLAGS=$(CXXFLAGS)
LDFLAGS=

objects = $(patsubst %,build/%, $(patsubst %.c,%.o, $(wildcard *.c)))
ruby_headers = $(patsubst %,build/%, $(patsubst lib/%.rb,%.h, $(wildcard lib/*.rb)))

$(target): $(build) $(objects) yaml/src/.libs/libyaml.a mruby/build/host/lib/libmruby.a $(ruby_headers)
	$(CXX) $(LDFLAGS) -o $@ $(objects) yaml/src/.libs/libyaml.a mruby/build/host/lib/libmruby.a

mruby/bin/mrbc:
	cd mruby && make

mruby/build/host/lib/libmruby.a:
	cd mruby && make

yaml/src/.libs/libyaml.a:
	cd yaml && make

$(build)/%.o: %.c $(ruby_headers)
	$(CC) $(CXXFLAGS) -c $< -o $@

#mruby/bin/mrbc -B init -o build/init.h lib/init.rb
$(build)/%.h: lib/%.rb mruby/bin/mrbc
	mruby/bin/mrbc -B $(patsubst build/%.h,%, $@) -o $@ $<

$(build):
	mkdir -p $(build)

clean:
	cd yaml && make clean
	cd mruby && make clean
	touch $(build) && rm -R $(build)
