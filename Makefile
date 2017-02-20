ifeq ($(strip $(DEVKITXENON)),)
$(error "please set DEVKITXENON")
endif

export PATH    	    := $(DEVKITXENON)/bin:$(PATH)

include $(DEVKITXENON)/rules

export BASEDIR      := $(CURDIR)
export DRIVERDIR    := $(BASEDIR)/drivers
export STARTUPDIR   := $(BASEDIR)/startup

export INCDIR  		:= $(BASEDIR)/include

# ipv4 or ipv6
LWIP_MODE = ipv4

INCLUDES = -I $(DRIVERDIR) -I $(INCDIR) \
       	-I $(DRIVERDIR)/nocfe \
       	-I $(DRIVERDIR)/lwip/include/ \
       	-I $(DRIVERDIR)/lwip/xenon/include/ \
       	-I $(DRIVERDIR)/lwip/include/$(LWIP_MODE)/

CFLAGS = -g -mcpu=cell -mtune=cell -Os \
       	-maltivec \
       	-ffunction-sections -fdata-sections \
       	-Wall -Wno-format -Wno-attributes -I. -DBYTE_ORDER=BIG_ENDIAN \
       	-m32 -fno-pic -mpowerpc64 \
       	-D_CFE_=1 -DENDIAN_BIG=1 \
       	$(INCLUDES)

# we need to fix the toolchain to work with multilib here.
LIBDIR32 = $(DEVKITXENON)/$(TARGET)/lib/32/

CXXFLAGS = $(CFLAGS) -fpermissive -Wno-sign-compare -Werror=int-to-pointer-cast \
       	-Werror=pointer-to-int-cast -Wno-unknown-pragmas  -Wno-unused-value -Wno-unused-variable

AFLAGS = -Iinclude -m32 $(INCLUDES)

LIBOBJS = $(STARTUPDIR)/crti.o \
		$(STARTUPDIR)/crtn.o \
		$(STARTUPDIR)/argv.o \
		$(STARTUPDIR)/startup_from_xell.o \
		$(STARTUPDIR)/crt1.o \
       	$(DRIVERDIR)/console/console.o \
       	$(DRIVERDIR)/console/telnet_console.o \
		$(DRIVERDIR)/diskio/ata.o \
       	$(DRIVERDIR)/iso9660/iso9660.o \
       	$(DRIVERDIR)/input/input.o \
       	$(DRIVERDIR)/newlib/newlib.o \
       	$(DRIVERDIR)/newlib/xenon_syscalls.o \
       	$(DRIVERDIR)/nocfe/lib_malloc.o \
       	$(DRIVERDIR)/nocfe/lib_queue.o \
       	$(DRIVERDIR)/pci/io.o \
       	$(DRIVERDIR)/ppc/atomic.o \
       	$(DRIVERDIR)/ppc/cache.o \
       	$(DRIVERDIR)/ppc/except.o \
       	$(DRIVERDIR)/ppc/c_except.o \
       	$(DRIVERDIR)/ppc/vm.o \
       	$(DRIVERDIR)/time/time.o \
       	$(DRIVERDIR)/usb/dummy.o \
       	$(DRIVERDIR)/usb/ohci.o \
       	$(DRIVERDIR)/usb/usbctrl.o \
       	$(DRIVERDIR)/usb/usbd.o \
       	$(DRIVERDIR)/usb/usbdebug.o \
       	$(DRIVERDIR)/usb/usbdevs.o \
       	$(DRIVERDIR)/usb/usbhid.o \
       	$(DRIVERDIR)/usb/usbhub.o \
       	$(DRIVERDIR)/usb/usbmain.o \
       	$(DRIVERDIR)/usb/usbmass.o \
       	$(DRIVERDIR)/usb/tinyehci/usb_os.o \
       	$(DRIVERDIR)/usb/tinyehci/tinyehci.o \
       	$(DRIVERDIR)/utils/debug.o \
       	$(DRIVERDIR)/utils/gmon.o \
       	$(DRIVERDIR)/utils/mf-simplecheck.o \
       	$(DRIVERDIR)/xenon_smc/xenon_gpio.o \
       	$(DRIVERDIR)/xenon_smc/xenon_smc.o \
       	$(DRIVERDIR)/xenon_soc/cpusleep.o \
       	$(DRIVERDIR)/xenon_soc/xenon_power.o \
       	$(DRIVERDIR)/xenon_soc/xenon_secotp.o \
       	$(DRIVERDIR)/xenon_sound/sound.o \
       	$(DRIVERDIR)/xenon_uart/xenon_uart.o \
       	$(DRIVERDIR)/xenon_nand/xenon_sfcx.o \
       	$(DRIVERDIR)/xenon_nand/xenon_config.o \
       	$(DRIVERDIR)/xenon_post/xenon_post.o \
       	$(DRIVERDIR)/xenos/ucode.o \
       	$(DRIVERDIR)/xenos/edram.o \
       	$(DRIVERDIR)/xenos/xe.o \
       	$(DRIVERDIR)/xenos/xenos.o \
       	$(DRIVERDIR)/xenos/xenos_edid.o \
       	$(DRIVERDIR)/lwip/core/init.o \
       	$(DRIVERDIR)/lwip/core/tcp_in.o \
       	$(DRIVERDIR)/lwip/core/ipv4/inet_chksum.o \
       	$(DRIVERDIR)/lwip/core/ipv4/inet.o \
       	$(DRIVERDIR)/lwip/core/mem.o \
       	$(DRIVERDIR)/lwip/core/dns.o \
       	$(DRIVERDIR)/lwip/core/memp.o \
       	$(DRIVERDIR)/lwip/core/netif.o \
       	$(DRIVERDIR)/lwip/core/pbuf.o \
       	$(DRIVERDIR)/lwip/core/stats.o \
       	$(DRIVERDIR)/lwip/core/sys.o \
       	$(DRIVERDIR)/lwip/core/tcp.o \
       	$(DRIVERDIR)/lwip/core/ipv4/ip_addr.o \
       	$(DRIVERDIR)/lwip/core/ipv4/icmp.o \
       	$(DRIVERDIR)/lwip/core/ipv4/ip.o \
       	$(DRIVERDIR)/lwip/core/ipv4/ip_frag.o \
       	$(DRIVERDIR)/lwip/core/tcp_out.o \
       	$(DRIVERDIR)/lwip/core/udp.o \
       	$(DRIVERDIR)/lwip/netif/etharp.o \
       	$(DRIVERDIR)/lwip/netif/loopif.o \
       	$(DRIVERDIR)/lwip/core/dhcp.o \
       	$(DRIVERDIR)/lwip/core/raw.o \
       	$(DRIVERDIR)/lwip/core/def.o \
       	$(DRIVERDIR)/lwip/core/timers.o \
       	$(DRIVERDIR)/lwip/xenon/src/lib.o \
       	$(DRIVERDIR)/lwip/xenon/netif/enet.o \
       	$(DRIVERDIR)/network/network.o\
       	$(DRIVERDIR)/elf/elf.o \
       	$(DRIVERDIR)/elf/elf_run.o \
       	$(DRIVERDIR)/libfdt/fdt.o \
       	$(DRIVERDIR)/libfdt/fdt_ro.o \
       	$(DRIVERDIR)/libfdt/fdt_rw.o \
       	$(DRIVERDIR)/libfdt/fdt_strerror.o \
       	$(DRIVERDIR)/libfdt/fdt_sw.o \
       	$(DRIVERDIR)/libfdt/fdt_wip.o \
        $(DRIVERDIR)/crypt/des.o \
        $(DRIVERDIR)/crypt/hmac_sha1.o \
        $(DRIVERDIR)/crypt/rc4.o \
        $(DRIVERDIR)/crypt/sha1.o \
        $(DRIVERDIR)/xb360/xb360.o

# Build rules
all: libxenon.a

clean:
	rm -rf $(OBJS) $(LIBOBJS) libxenon.a
	find $(BASEDIR) -name "*.d" -type f -delete 

.c.o:
	@echo $(notdir $<)
	@$(CC) -c $(CFLAGS) $*.c -o $*.o

.cpp.o:
	@echo $(notdir $<)
	@$(CXX) -c $(CXXFLAGS) $*.cpp -o $*.o

%.o: %.S
	@echo $(notdir $<)
	@$(CC) $(AFLAGS) -c $*.S -o $*.o

%.o: %.s
	@echo $(notdir $<)
	@$(CC) $(AFLAGS) -c $*.s -o $*.o

libxenon.a: $(LIBOBJS)
	ar rc $@ $(LIBOBJS)

install: libxenon.a
	@mkdir -p $(DEVKITXENON)/usr/lib/
	@mkdir -p $(DEVKITXENON)/usr/include/
	@mkdir -p $(DEVKITXENON)/usr/include/sys
	@mkdir -p $(DEVKITXENON)/usr/include/lwip/
	@mkdir -p $(DEVKITXENON)/usr/include/netif/
	@mkdir -p $(DEVKITXENON)/usr/include/arch/
	@mkdir -p $(DEVKITXENON)/usr/include/sys/
	@mkdir -p $(DEVKITXENON)/$(TARGET)/lib/

	@echo [ Installing headers to $(DEVKITXENON)/usr/include ]
	cp -r $(DRIVERDIR)/* $(DEVKITXENON)/usr/include/
	cp -r $(INCDIR)/* $(DEVKITXENON)/usr/include/

	install -m 0664 $(DRIVERDIR)/lwip/include/lwip/* $(DEVKITXENON)/usr/include/lwip/
	install -m 0664 $(DRIVERDIR)/lwip/include/$(LWIP_MODE)/lwip/* $(DEVKITXENON)/usr/include/lwip/
	install -m 0664 $(DRIVERDIR)/lwip/include/netif/* $(DEVKITXENON)/usr/include/netif/
	install -m 0664 $(DRIVERDIR)/lwip/xenon/include/arch/* $(DEVKITXENON)/usr/include/arch/

	@echo [ Installing crtls to $(DEVKITXENON)/$(TARGET)/lib ]
	install -m 0664 $(STARTUPDIR)/crt1.o $(DEVKITXENON)/$(TARGET)/lib/
	install -m 0664 $(STARTUPDIR)/crti.o $(DEVKITXENON)/$(TARGET)/lib/
	install -m 0664 $(STARTUPDIR)/crtn.o $(DEVKITXENON)/$(TARGET)/lib/

	@echo [ Installing LibXenon to $(DEVKITXENON)/usr/lib ]
	install -m 0664 libxenon.a $(DEVKITXENON)/usr/lib/

	@find $(DEVKITXENON)/usr/include/ -type f \! -name "*.h" -delete
