OUTPUT_ARCH("riscv")
MEMORY
{
	/* ArtyA7, CmodA7 */
/*
	RAM (rwx)     : ORIGIN = 0x80000000, LENGTH = 0x0000B800
	CCRAM (rwx)   : ORIGIN = 0x8000B800, LENGTH = 0x00004000		
	EXT_MEM (rwx) : ORIGIN = 0x8000C800, LENGTH = 0x00000000
*/

	/* NexysVideo */
	
	RAM (rwx)     : ORIGIN = 0x80000000, LENGTH = 0x00057400
	CCRAM (rwx)   : ORIGIN = 0x80057400, LENGTH = 0x00004000		
	EXT_MEM (rwx) : ORIGIN = 0x8005B400, LENGTH = 0x00000000

}

ENTRY(_reset_entry)
SECTIONS
{					
	. = 0x80000000;
	
	.init : {
	KEEP (*(SORT_NONE(.init)))
        } > RAM
        
	.reset_entry : { crt0.o(.text) } > RAM
	
	.text : { 
		. = ALIGN(4);
		_stext = .;
		*(.text.unlikely .text.unlikely.*)
		*(.text.startup .text.startup.*)
		*(.text .text.*) 
		*(.gnu.linkonce.t.*)
		} > RAM
		
	.fini : {
	    KEEP (*(SORT_NONE(.fini)))
	} > RAM
	
	.rodata : { 
	    *(.rdata)
	    *(.rodata .rodata.*) 
	    *(.gnu.linkonce.r.*)
	} > RAM
	. = ALIGN(4);

	.srodata : { *(.srodata) } > RAM
	
	.data : { 
		. = ALIGN(4);
		*(.data)
		*(.data.*)
		_end_data = .;
		} > RAM
		
	__global_pointer$ = .;
	
	.sdata : { *(.sdata) } > RAM

	.bss : {
		. = ALIGN(4); 
		_bss_start = .;
		*(.bss) 
		*(.bss.*)
		*(.sbss)
		*(.sbss.*)		
		_bss_end = .;
		} > RAM

    .heap : {
	    . = ALIGN(4);
        _end = .;
        /* _heap_start = .; */
        /* "end" is used by newlib's syscalls!!! */
        PROVIDE(end = .);
        PROVIDE(_heap_start = end );
        PROVIDE(_heap_end = .);
    } >RAM


    .stack_dummy (COPY) : {
        _end_stack = .;
        *(.stack*)
    } > CCRAM

    /* Set stack top to end of RAM, and stack limit move down by
     * size of stack_dummy section */
    _stack_start = ORIGIN(CCRAM) + LENGTH(CCRAM);
    _stack_size = _stack_start - SIZEOF(.stack_dummy);
    PROVIDE(__stack = _stack_start);
		

	.ext_mem : {
		_EXT_MEM_START = .;
		KEEP(*(.extMem))	
		_EXT_MEM_END = .;
	} > EXT_MEM
	
	/* define labels for the system timer, so 
	   crt0 can easily initialize timer registers */
	_timer_regh = 0xc0000014;
	_timer_regl = 0xc0000010;
	_timer_compregh = 0xc000001C;
	_timer_compregl = 0xc0000018;
}
