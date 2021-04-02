/* modified for libxenon */

/***************************************************************************
 *             __________               __   ___.
 *   Open      \______   \ ____   ____ |  | _\_ |__   _______  ___
 *   Source     |       _//  _ \_/ ___\|  |/ /| __ \ /  _ \  \/  /
 *   Jukebox    |    |   (  <_> )  \___|    < | \_\ (  <_> > <  <
 *   Firmware   |____|_  /\____/ \___  >__|_ \|___  /\____/__/\_ \
 *                     \/            \/     \/    \/            \/
 * $Id$
 *
 * Copyright (C) 2002 by Björn Stenberg
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 ****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include "disk_rb.h"
#include <string.h>
#include <fat/fat_rb.h>
#include <fat/dir_rb.h>

/* Partition table entry layout:
   -----------------------
   0: 0x80 - active
   1: starting head
   2: starting sector
   3: starting cylinder
   4: partition type
   5: end head
   6: end sector
   7: end cylinder
   8-11: starting sector (LBA)
   12-15: nr of sectors in partition
*/

#define BYTES2INT32(array,pos)                  \
    ((long)array[pos] | ((long)array[pos+1] << 8 ) |        \
     ((long)array[pos+2] << 16 ) | ((long)array[pos+3] << 24 ))

static const unsigned char fat_partition_types[] = {
    0x0b, 0x1b, /* FAT32 + hidden variant */
    0x0c, 0x1c, /* FAT32 (LBA) + hidden variant */
#ifdef HAVE_FAT16SUPPORT
    0x04, 0x14, /* FAT16 <= 32MB + hidden variant */
    0x06, 0x16, /* FAT16  > 32MB + hidden variant */
    0x0e, 0x1e, /* FAT16 (LBA) + hidden variant */
#endif
};

static struct partinfo part[MAXDEVICES*4]; /* space for 4 partitions on 2 drives */
static int vol_drive[MAXMOUNT]; /* mounted to which drive (-1 if none) */

#ifdef MAX_LOG_SECTOR_SIZE
int disk_sector_multiplier = 1;
#endif

extern struct bdev devices[MAXDEVICES]; // TODO

// must be a power of 2
#define BLOCK_CACHE_SECTOR_COUNT 128
#define BAD_LBA -1

static unsigned char block_cache[MAXDEVICES][BLOCK_CACHE_SECTOR_COUNT][SECTOR_SIZE];
static lba_t block_cache_lba[MAXDEVICES];

struct partinfo* disk_init(IF_MD_NONVOID(int drive))
{
    int i;
    unsigned char sector[SECTOR_SIZE];
#ifdef HAVE_MULTIDRIVE
    /* For each drive, start at a different position, in order not to destroy 
       the first entry of drive 0. 
       That one is needed to calculate config sector position. */
    struct partinfo* pinfo = &part[drive*4];
    if ((size_t)drive >= sizeof(part)/sizeof(*part)/4)
        return NULL; /* out of space in table */

#else
    struct partinfo* pinfo = part;
    const int drive = 0;
    (void)drive;
#endif

	block_cache_lba[drive]=BAD_LBA;

    storage_read_sectors(IF_MD2(drive,) 0,1, sector);
    /* check that the boot sector is initialized */
    if ( (sector[510] != 0x55) ||
         (sector[511] != 0xaa)) {
        DEBUGF("Bad boot sector signature\n");
        return NULL;
    }

    /* parse partitions */
    for ( i=0; i<4; i++ ) {
        unsigned char* ptr = sector + 0x1be + 16*i;
        pinfo[i].type  = ptr[4];
        pinfo[i].start = BYTES2INT32(ptr, 8);
        pinfo[i].size  = BYTES2INT32(ptr, 12);

        DEBUGF("Part%d: Type %02x, start: %08lx size: %08lx\n",
               i,pinfo[i].type,pinfo[i].start,pinfo[i].size);

        /* extended? */
        if ( pinfo[i].type == 5 ) {
            /* not handled yet */
        }
    }
    return pinfo;
}

struct partinfo* disk_partinfo(int partition)
{
    return &part[partition];
}

#if 0 // libxenon edit

int disk_mount_all(void)
{
    int mounted=0;
    int i;
    
#ifdef HAVE_HOTSWAP
    card_enable_monitoring(false);
#endif

    fat_init(); /* reset all mounted partitions */
    for (i=0; i<NUM_VOLUMES; i++)
        vol_drive[i] = -1; /* mark all as unassigned */

#ifndef HAVE_MULTIDRIVE
    mounted = disk_mount(0);
#else
    for(i=0;i<NUM_DRIVES;i++)
    {
#ifdef HAVE_HOTSWAP
        if (storage_present(i))
#endif
            mounted += disk_mount(i); 
    }
#endif

#ifdef HAVE_HOTSWAP
    card_enable_monitoring(true);
#endif

    return mounted;
}

static int get_free_volume(void)
{
    int i;
    for (i=0; i<NUM_VOLUMES; i++)
    {
        if (vol_drive[i] == -1) /* unassigned? */
            return i;
    }

    return -1; /* none found */
}
#endif

int disk_mount(int drive, int volume)
{
    int mounted = 0; /* reset partition-on-drive flag */
// libxenon edit    int volume = get_free_volume();
    struct partinfo* pinfo = disk_init(IF_MD(drive));

    if (pinfo == NULL)
    {
        return 0;
    }
    int i = 0;
    for (; volume != -1 && i<4 && mounted<NUM_VOLUMES_PER_DRIVE; i++)
    {
        if (memchr(fat_partition_types, pinfo[i].type,
                   sizeof(fat_partition_types)) == NULL)
            continue;  /* not an accepted partition type */

#ifdef MAX_LOG_SECTOR_SIZE
        int j;
        
        for (j = 1; j <= (MAX_LOG_SECTOR_SIZE/SECTOR_SIZE); j <<= 1)
        {
            if (!fat_mount(IF_MV2(volume,) IF_MD2(drive,) pinfo[i].start * j))
            {
                pinfo[i].start *= j;
                pinfo[i].size *= j;
                mounted++;
                vol_drive[volume] = drive; /* remember the drive for this volume */
                volume = get_free_volume(); /* prepare next entry */
                if (drive == 0)
                    disk_sector_multiplier = j;
                break;
            }
        }
#else
        if (!fat_mount(IF_MV2(volume,) IF_MD2(drive,) pinfo[i].start))
        {
            mounted++;
            vol_drive[volume] = drive; /* remember the drive for this volume */
 // libxenon edit            volume = get_free_volume(); /* prepare next entry */
        }
#endif
    }

    if (mounted == 0 && volume != -1) /* none of the 4 entries worked? */
    {   /* try "superfloppy" mode */
        DEBUGF("No partition found, trying to mount sector 0.\n");
        if (!fat_mount(IF_MV2(volume,) IF_MD2(drive,) 0))
        {
            mounted = 1;
            vol_drive[volume] = drive; /* remember the drive for this volume */
        }
    }
    return mounted;
}

#ifdef HAVE_HOTSWAP
int disk_unmount(int drive)
{
    int unmounted = 0;
    int i;
    for (i=0; i<MAXMOUNT; i++)
    {
        if (vol_drive[i] == drive)
        {   /* force releasing resources */
            vol_drive[i] = -1; /* mark unused */
            unmounted++;
            release_files(i);
            release_dirs(i);
            fat_unmount(i, false);
        }
    }

    return unmounted;
}
#endif /* #ifdef HAVE_HOTSWAP */


int storage_read_sectors(int drive, unsigned long start, int count, void* buf)
{
	int red=0;

//	printf("[storage_read_sectors] device %s start %ld count %d\n",devices[drive].name,start,count);
	
	if(count!=1){
		red=devices[drive].ops->read(&devices[drive],buf,start,count);
	}else{
		if(block_cache_lba[drive]==BAD_LBA || start<block_cache_lba[drive] || start>=block_cache_lba[drive]+BLOCK_CACHE_SECTOR_COUNT){
			block_cache_lba[drive]=start&~(BLOCK_CACHE_SECTOR_COUNT-1);
			
//			printf("reading at %d\n",block_cache_lba);
			red=devices[drive].ops->read(&devices[drive],block_cache[drive],block_cache_lba[drive],BLOCK_CACHE_SECTOR_COUNT);
			
			if(red!=BLOCK_CACHE_SECTOR_COUNT){
				red=devices[drive].ops->read(&devices[drive],buf,start,1);
				block_cache_lba[drive]=BAD_LBA;
			}
		}
		
		if(block_cache_lba[drive]!=BAD_LBA){
			red=1;
			memcpy(buf,block_cache[drive][start-block_cache_lba[drive]],SECTOR_SIZE);
		}
	}

	return count-red;
}

int storage_write_sectors(int drive, unsigned long start, int count, const void* buf)
{
	// Invalide cache
	block_cache_lba[drive]=BAD_LBA;
	int red = devices[drive].ops->write(&devices[drive],buf,start,count);
	
	return count-red;
}
