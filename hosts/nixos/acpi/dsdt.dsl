/*
 * PATCHED DSDT for the Minisforum V3 (MB8) -- dumped from this machine and
 * decompiled with iasl (acpica-tools), then edited. Built by
 * modules/hardware/tablet.nix into an initrd ACPI table override; see that
 * file for why an override is used instead of a kernel patch.
 *
 * Dump: AMI BIOS 1.05 (bvr 1.05, bd 04/10/2024, br 5.29, ef 8.8),
 *       from /sys/firmware/acpi/tables/DSDT, 28065 bytes,
 *       OEM id "ALASKA" / "A M I ", OEM revision 0x01072009.
 *       If a BIOS update changes the DSDT, re-dump this file; the override is
 *       a whole-table replacement, not a patch, so it silently supersedes
 *       whatever the new firmware ships. The kernel validates signature,
 *       length and checksum and refuses the table if any of them disagree.
 *
 * Three edits, all of them identifiers -- no AML logic is touched:
 *
 *   1. \_SB.I2CD.STS   _HID/_CID  EisaId ("SMOCF05") -> EisaId ("SMO8B30")
 *      The LSM6DS3TRC accelerometer on i2c bus 1. The ACPI namespace uses a
 *      made-up HID that no in-tree driver claims, so the device is enumerated
 *      (i2c-SMOCF05:00 exists) but nothing probes it. "SMO8B30" is the HID the
 *      stock st_lsm6dsx_i2c driver already lists in its of/acpi table, mapped to
 *      ST_LSM6DS3TRC_ID. Renaming the device in ASL is what makes the existing
 *      driver bind -- the same effect the kernel patch achieved, with no
 *      rebuild.
 *
 *   2. \_SB.PCI0.SBRG.CIND  _HID  "ID9001" -> "INT33D3"
 *      A GPIO sensor behind 23 pins at \_SB.GP, with _CID PNP0C60 (HID
 *      sensor device). Nothing in the tree claims ID9001 today, so it is
 *      unbound and does nothing; INT33D3 is the HID the vendor's own fix uses.
 *      Carried over unchanged in intent from the Arch fix this replaces.
 *
 *   3. OEM revision 0x01072009 -> 0x01072019
 *      Bumped so the table is not mistaken for the firmware's own. The kernel
 *      taints itself with TAINT_OVERRIDDEN_ACPI_TABLE when it installs an
 *      override and prints a warning; that is expected here and is the same
 *      trade-off every distro that ships this table makes.
 *
 * Note on edit 2 and iasl: the original _HID is the six-character string
 * "ID9001". iasl refuses to compile a _HID string that is not 7 or 8
 * characters (Error 6033), so the unpatched dump does not compile with a
 * current acpica-tools. That is a reason the file has to be edited, not a
 * reason to distrust the result: the ACPI bus converts a string _HID into an
 * EISA ID, which is how ID9001 ends up in this machine's modalias
 * (acpi:ID9001:PNP0C60:) today.
 */

/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20260408 (64-bit version)
 * Copyright (c) 2000 - 2026 Intel Corporation
 * 
 * Disassembling to symbolic ASL+ operators
 *
 * Disassembly of DSDT.aml
 *
 * Original Table Header:
 *     Signature        "DSDT"
 *     Length           0x00006DA1 (28065)
 *     Revision         0x02
 *     Checksum         0x1B
 *     OEM ID           "ALASKA"
 *     OEM Table ID     "A M I "
 *     OEM Revision     0x01072009 (17244169)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20220331 (539099953)
 */
DefinitionBlock ("", "DSDT", 2, "ALASKA", "A M I ", 0x01072019)
{
    External (_SB_.APTS, MethodObj)    // 1 Arguments
    External (_SB_.AWAK, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.GP17.VGA_.AFN7, MethodObj)    // 1 Arguments
    External (_SB_.PCI0.GP17.VGA_.M460, MethodObj)    // 7 Arguments
    External (AFN4, MethodObj)    // 1 Arguments
    External (ALIB, MethodObj)    // 2 Arguments
    External (CRBI, UnknownObj)
    External (M460, MethodObj)    // 7 Arguments
    External (M600, MethodObj)    // 2 Arguments
    External (M601, MethodObj)    // 6 Arguments
    External (MPTS, MethodObj)    // 1 Arguments
    External (MWAK, MethodObj)    // 1 Arguments
    External (SMIE, UnknownObj)

    Name (IO1B, 0x0A00)
    Name (IO1L, 0x10)
    Name (IO2B, 0x0A10)
    Name (IO2L, 0x20)
    Name (IO3B, 0x0A30)
    Name (IO3L, 0x20)
    Name (IO4B, 0x0A50)
    Name (IO4L, 0x20)
    Name (IO5B, 0x0A70)
    Name (IO5L, 0x10)
    Name (IO6B, 0x0A80)
    Name (IO6L, 0x10)
    Name (SP1O, 0x2E)
    Name (IOES, Zero)
    Name (PEBL, 0x10000000)
    Name (NBTS, 0x5000)
    Name (CPVD, One)
    Name (SMBB, 0x0B20)
    Name (SMBL, 0x20)
    Name (SMB0, 0x0B00)
    Name (SMBM, 0x10)
    Name (PMBS, 0x0800)
    Name (PMLN, 0xA0)
    Name (SMIO, 0xB2)
    Name (APCB, 0xFEC00000)
    Name (APCL, 0x1000)
    Name (HPTB, 0xFED00000)
    Name (WDTB, Zero)
    Name (WDTL, Zero)
    Name (GIOB, 0xFED81500)
    Name (IOMB, 0xFED80D00)
    Name (SSMB, 0xFED80200)
    Name (UTDB, Zero)
    Name (ASSB, Zero)
    Name (AOTB, Zero)
    Name (AAXB, Zero)
    Name (PEHP, One)
    Name (SHPC, One)
    Name (PEPM, One)
    Name (PEER, One)
    Name (PECS, One)
    Name (ITKE, Zero)
    Name (PEBS, 0xE0000000)
    Name (PELN, 0x10000000)
    Name (CSMI, 0x61)
    Name (SMIA, 0xB2)
    Name (SMIB, 0xB3)
    Name (OFST, 0x35)
    Name (TRST, 0x02)
    Name (TCMF, Zero)
    Name (TMF1, Zero)
    Name (TMF2, Zero)
    Name (TMF3, Zero)
    Name (TTPF, Zero)
    Name (DTPT, Zero)
    Name (TTDP, One)
    Name (TPMB, 0xFFFFFFFF)
    Name (TPBS, 0x1000)
    Name (TPMC, 0xFFFFFFFF)
    Name (TPCS, 0x1000)
    Name (TPMM, 0xFED40000)
    Name (FTPM, 0xFFFFFFFF)
    Name (PPIM, 0x9720CF18)
    Name (PPIL, 0x1C)
    Name (TPMF, One)
    Name (PPIV, One)
    Name (AMDT, 0x02)
    Name (MBEC, Zero)
    Name (NBTP, 0xFEC00000)
    Method (_PIC, 1, NotSerialized)  // _PIC: Interrupt Model
    {
        If (Arg0)
        {
            \_SB.DSPI ()
            \_SB.PCI0.NAPE ()
        }

        PXXX (Arg0)
    }

    OperationRegion (DEB0, SystemIO, 0x80, 0x04)
    Field (DEB0, DWordAcc, NoLock, Preserve)
    {
        DBG8,   32
    }

    Name (PICM, Zero)
    Method (PXXX, 1, NotSerialized)
    {
        If (Arg0)
        {
            DBGX = 0xAA
        }
        Else
        {
            DBGX = 0xAC
        }

        PICM = Arg0
    }

    Name (OSVR, Ones)
    Method (OSFL, 0, NotSerialized)
    {
        If ((OSVR != Ones))
        {
            Return (OSVR) /* \OSVR */
        }

        If ((PICM == Zero))
        {
            DBGX = 0xAC
        }

        OSVR = 0x03
        If (CondRefOf (\_OSI))
        {
            If (_OSI ("Windows 2001"))
            {
                OSVR = 0x04
            }

            If (_OSI ("Windows 2001.1"))
            {
                OSVR = 0x05
            }

            If (_OSI ("FreeBSD"))
            {
                OSVR = 0x06
            }

            If (_OSI ("HP-UX"))
            {
                OSVR = 0x07
            }

            If (_OSI ("OpenVMS"))
            {
                OSVR = 0x08
            }

            If (_OSI ("Windows 2001 SP1"))
            {
                OSVR = 0x09
            }

            If (_OSI ("Windows 2001 SP2"))
            {
                OSVR = 0x0A
            }

            If (_OSI ("Windows 2001 SP3"))
            {
                OSVR = 0x0B
            }

            If (_OSI ("Windows 2006"))
            {
                OSVR = 0x0C
            }

            If (_OSI ("Windows 2006 SP1"))
            {
                OSVR = 0x0D
            }

            If (_OSI ("Windows 2009"))
            {
                OSVR = 0x0E
            }

            If (_OSI ("Windows 2012"))
            {
                OSVR = 0x0F
            }

            If (_OSI ("Windows 2013"))
            {
                OSVR = 0x10
            }
        }
        Else
        {
            If (MCTH (_OS, "Microsoft Windows NT"))
            {
                OSVR = Zero
            }

            If (MCTH (_OS, "Microsoft Windows"))
            {
                OSVR = One
            }

            If (MCTH (_OS, "Microsoft WindowsME: Millennium Edition"))
            {
                OSVR = 0x02
            }

            If (MCTH (_OS, "Linux"))
            {
                OSVR = 0x03
            }

            If (MCTH (_OS, "FreeBSD"))
            {
                OSVR = 0x06
            }

            If (MCTH (_OS, "HP-UX"))
            {
                OSVR = 0x07
            }

            If (MCTH (_OS, "OpenVMS"))
            {
                OSVR = 0x08
            }
        }

        Return (OSVR) /* \OSVR */
    }

    Method (MCTH, 2, NotSerialized)
    {
        If ((SizeOf (Arg0) < SizeOf (Arg1)))
        {
            Return (Zero)
        }

        Local0 = (SizeOf (Arg0) + One)
        Name (BUF0, Buffer (Local0){})
        Name (BUF1, Buffer (Local0){})
        BUF0 = Arg0
        BUF1 = Arg1
        While (Local0)
        {
            Local0--
            If ((DerefOf (BUF0 [Local0]) != DerefOf (BUF1 [Local0]
                )))
            {
                Return (Zero)
            }
        }

        Return (One)
    }

    Name (PRWP, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (GPRW, 2, NotSerialized)
    {
        PRWP [Zero] = Arg0
        Local0 = (SS1 << One)
        Local0 |= (SS2 << 0x02)
        Local0 |= (SS3 << 0x03)
        Local0 |= (SS4 << 0x04)
        If (((One << Arg1) & Local0))
        {
            PRWP [One] = Arg1
        }
        Else
        {
            Local0 >>= One
            If (((OSFL () == One) || (OSFL () == 0x02)))
            {
                FindSetLeftBit (Local0, PRWP [One])
            }
            Else
            {
                FindSetRightBit (Local0, PRWP [One])
            }
        }

        If ((DAS3 == Zero))
        {
            If ((Arg1 <= 0x03))
            {
                PRWP [One] = Zero
            }
        }

        Return (PRWP) /* \PRWP */
    }

    Name (WAKP, Package (0x02)
    {
        Zero, 
        Zero
    })
    Method (UPWP, 1, NotSerialized)
    {
        If (DerefOf (WAKP [Zero]))
        {
            WAKP [One] = Zero
        }
        Else
        {
            WAKP [One] = Arg0
        }
    }

    OperationRegion (DEB3, SystemIO, 0x80, One)
    Field (DEB3, ByteAcc, NoLock, Preserve)
    {
        DBGX,   8
    }

    OperationRegion (DEB1, SystemIO, 0x90, 0x02)
    Field (DEB1, WordAcc, NoLock, Preserve)
    {
        DBG9,   16
    }

    Name (SS1, Zero)
    Name (SS2, Zero)
    Name (SS3, Zero)
    Name (SS4, One)
    Name (IOST, 0xC400)
    Name (TOPM, 0x00000000)
    Name (ROMS, 0xFFE00000)
    Name (VGAF, One)
    OperationRegion (GNVS, SystemMemory, 0x971F9D18, 0x0D)
    Field (GNVS, AnyAcc, Lock, Preserve)
    {
        CNSB,   8, 
        RDHW,   8, 
        DAS3,   8, 
        ALST,   8, 
        BLTH,   8, 
        NFCS,   8, 
        MWTT,   8, 
        DPTC,   8, 
        WOVS,   8, 
        THPN,   8, 
        THPD,   8, 
        RV2I,   8, 
        ISDS,   8
    }

    OperationRegion (DEB2, SystemIO, 0x80, 0x04)
    Field (DEB2, DWordAcc, NoLock, Preserve)
    {
        P80H,   32
    }

    Name (OSTY, Ones)
    OperationRegion (ACMS, SystemIO, 0x72, 0x02)
    Field (ACMS, ByteAcc, NoLock, Preserve)
    {
        ACMX,   8, 
        ACMA,   8
    }

    IndexField (ACMX, ACMA, ByteAcc, NoLock, Preserve)
    {
        Offset (0xB9), 
        IMEN,   8
    }

    OperationRegion (PSMI, SystemIO, SMIO, 0x02)
    Field (PSMI, ByteAcc, NoLock, Preserve)
    {
        APMC,   8, 
        APMD,   8
    }

    OperationRegion (PMRG, SystemMemory, 0xFED80300, 0x0100)
    Field (PMRG, AnyAcc, NoLock, Preserve)
    {
            ,   6, 
        HPEN,   1, 
        Offset (0x60), 
        P1EB,   16, 
        Offset (0xF0), 
            ,   3, 
        RSTU,   1
    }

    OperationRegion (GSMG, SystemMemory, 0xFED81500, 0x03FF)
    Field (GSMG, AnyAcc, NoLock, Preserve)
    {
        Offset (0x5C), 
        Offset (0x5E), 
        GS23,   1, 
            ,   5, 
        GV23,   1, 
        GE23,   1, 
        Offset (0xA0), 
        Offset (0xA2), 
        GS40,   1, 
            ,   5, 
        GV40,   1, 
        GE40,   1
    }

    OperationRegion (GSMM, SystemMemory, 0xFED80000, 0x1000)
    Field (GSMM, AnyAcc, NoLock, Preserve)
    {
        Offset (0x288), 
            ,   1, 
        CLPS,   1, 
        Offset (0x296), 
            ,   7, 
        TMSE,   1, 
        Offset (0x2B0), 
            ,   2, 
        SLPS,   2
    }

    OperationRegion (PMI2, SystemMemory, 0xFED80300, 0x0100)
    Field (PMI2, AnyAcc, NoLock, Preserve)
    {
        Offset (0xBB), 
            ,   6, 
        PWDE,   1, 
        Offset (0xBC)
    }

    OperationRegion (P1E0, SystemIO, P1EB, 0x04)
    Field (P1E0, ByteAcc, NoLock, Preserve)
    {
        Offset (0x01), 
            ,   6, 
        PEWS,   1, 
        WSTA,   1, 
        Offset (0x03), 
            ,   6, 
        PEWD,   1
    }

    OperationRegion (IOCC, SystemIO, PMBS, 0x80)
    Field (IOCC, ByteAcc, NoLock, Preserve)
    {
        Offset (0x01), 
            ,   2, 
        RTCS,   1
    }

    Method (SPTS, 1, NotSerialized)
    {
        P80H = Arg0
        If ((Arg0 == 0x03))
        {
            RSTU = Zero
        }

        CLPS = One
        SLPS = One
        PEWS = PEWS /* \PEWS */
        If ((Arg0 == 0x03))
        {
            SLPS = One
        }

        If ((Arg0 == 0x04))
        {
            SLPS = One
            RSTU = One
        }

        If ((Arg0 == 0x05))
        {
            PWDE = One
        }
    }

    Method (SWAK, 1, NotSerialized)
    {
        \_SB.ACAD.ACDC = 0xFF
        If ((Arg0 == 0x03))
        {
            RSTU = One
        }

        PEWS = PEWS /* \PEWS */
        PEWD = Zero
        If (PICM)
        {
            \_SB.DSPI ()
        }

        If (TMSE)
        {
            TMSE = Zero
        }

        If ((Arg0 == 0x03))
        {
            Notify (\_SB.PWRB, 0x02) // Device Wake
        }

        If ((Arg0 == 0x04))
        {
            Notify (\_SB.PWRB, 0x02) // Device Wake
            Sleep (0x50)
        }
    }

    Scope (_GPE)
    {
    }

    Scope (_SB)
    {
        Name (PRSA, Buffer (0x06)
        {
             0x23, 0x70, 0xCC, 0x18, 0x79, 0x00               // #p..y.
        })
        Alias (PRSA, PRSB)
        Alias (PRSA, PRSC)
        Alias (PRSA, PRSD)
        Alias (PRSA, PRSE)
        Alias (PRSA, PRSF)
        Alias (PRSA, PRSG)
        Alias (PRSA, PRSH)
        Name (PD12, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKH, , 
                Zero
            }
        })
        Name (AR12, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x1C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1D
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1F
            }
        })
        Name (PD14, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (AR14, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x20
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x21
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x22
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x23
            }
        })
        Name (PD10, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (AR10, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x18
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x19
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1B
            }
        })
        Name (PD16, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKF, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKH, , 
                Zero
            }
        })
        Name (AR16, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x24
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x25
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x26
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x27
            }
        })
        Name (PD18, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (AR18, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x28
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x29
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2B
            }
        })
        Name (PD22, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (AR22, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2D
            }
        })
        Name (PD24, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (AR24, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2D
            }
        })
        Name (PD26, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (AR26, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2B
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x28
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x29
            }
        })
        Name (PD28, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (AR28, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x26
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x27
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x24
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x25
            }
        })
        Name (PD2A, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (AR2A, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x22
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x23
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x20
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x21
            }
        })
        Name (PD30, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (AR30, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x1E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x1F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x1C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x1D
            }
        })
        Name (PD60, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (AR60, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x22
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x23
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x20
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x21
            }
        })
        Name (PD90, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (AR90, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x26
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x27
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x24
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x25
            }
        })
        Name (PD92, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKD, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKB, , 
                Zero
            }
        })
        Name (AR92, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2A
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2B
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x28
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x29
            }
        })
        Name (PD94, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                LNKG, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                LNKH, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                LNKE, , 
                Zero
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                LNKF, , 
                Zero
            }
        })
        Name (AR94, Package (0x04)
        {
            Package (0x04)
            {
                0xFFFF, 
                Zero, 
                Zero, 
                0x2E
            }, 

            Package (0x04)
            {
                0xFFFF, 
                One, 
                Zero, 
                0x2F
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x02, 
                Zero, 
                0x2C
            }, 

            Package (0x04)
            {
                0xFFFF, 
                0x03, 
                Zero, 
                0x2D
            }
        })
        Name (PD00, Package (0x04)
        {
            Package (0x04)
            {
                0x0014FFFF, 
                Zero, 
                LNKA, , 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                One, 
                LNKB, , 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x02, 
                LNKC, , 
                Zero
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x03, 
                LNKD, , 
                Zero
            }
        })
        Name (AR00, Package (0x04)
        {
            Package (0x04)
            {
                0x0014FFFF, 
                Zero, 
                Zero, 
                0x10
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                One, 
                Zero, 
                0x11
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x02, 
                Zero, 
                0x12
            }, 

            Package (0x04)
            {
                0x0014FFFF, 
                0x03, 
                Zero, 
                0x13
            }
        })
    }

    Scope (_SB)
    {
        Device (PCI0)
        {
            Name (_HID, EisaId ("PNP0A08") /* PCI Express Bus */)  // _HID: Hardware ID
            Name (_CID, EisaId ("PNP0A03") /* PCI Bus */)  // _CID: Compatible ID
            Name (_ADR, Zero)  // _ADR: Address
            Method (^BN00, 0, NotSerialized)
            {
                Return (Zero)
            }

            Method (_BBN, 0, NotSerialized)  // _BBN: BIOS Bus Number
            {
                Return (BN00 ())
            }

            Name (_UID, Zero)  // _UID: Unique ID
            Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
            {
                If (PICM)
                {
                    Return (AR00) /* \_SB_.AR00 */
                }

                Return (PD00) /* \_SB_.PD00 */
            }

            Device (AMDN)
            {
                Name (_HID, EisaId ("PNP0C01") /* System Board */)  // _HID: Hardware ID
                Name (_UID, 0xC8)  // _UID: Unique ID
                Name (_STA, 0x0F)  // _STA: Status
                Name (NPTR, Buffer (0x0E)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
                })
                Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                {
                    CreateDWordField (NPTR, 0x08, PL)
                    CreateDWordField (NPTR, 0x04, PB)
                    PB = PEBS /* \PEBS */
                    PL = PEBL /* \PEBL */
                    Return (NPTR) /* \_SB_.PCI0.AMDN.NPTR */
                }
            }

            Method (NPTS, 1, NotSerialized)
            {
                APTS (Arg0)
            }

            Method (NWAK, 1, NotSerialized)
            {
                AWAK (Arg0)
            }

            Name (CPRB, One)
            Name (LVGA, 0x01)
            Name (STAV, 0x0F)
            Name (BRB, 0x0000)
            Name (BRL, 0x0100)
            Name (IOB, 0x1000)
            Name (IOL, 0xF000)
            Name (MBB, 0xA0000000)
            Name (MBL, 0x40000000)
            Name (MAB, 0x0000000860000000)
            Name (MAL, 0x00000077A0000000)
            Name (MAM, 0x0000007FFFFFFFFF)
            Name (NRSB, 0x971FA000)
            OperationRegion (NRSV, SystemMemory, NRSB, 0x1000)
            Field (NRSV, AnyAcc, NoLock, Preserve)
            {
                RSTE,   32, 
                Offset (0x08), 
                Offset (0x10), 
                RSB0,   32, 
                Offset (0x18), 
                RSS0,   32, 
                Offset (0x20), 
                RSB1,   32, 
                Offset (0x28), 
                RSS1,   32, 
                Offset (0x30), 
                RSB2,   32, 
                Offset (0x38), 
                RSS2,   32, 
                Offset (0x40), 
                RSB3,   32, 
                Offset (0x48), 
                RSS3,   32, 
                Offset (0x50)
            }

            Name (CRS1, Buffer (0x0124)
            {
                /* 0000 */  0x88, 0x0D, 0x00, 0x02, 0x0C, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x00, 0x00, 0x7F, 0x00, 0x00, 0x00, 0x80, 0x00,  // ........
                /* 0010 */  0x47, 0x01, 0xF8, 0x0C, 0xF8, 0x0C, 0x01, 0x08,  // G.......
                /* 0018 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0020 */  0x00, 0x00, 0xAF, 0x03, 0x00, 0x00, 0xB0, 0x03,  // ........
                /* 0028 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0030 */  0xE0, 0x03, 0xF7, 0x0C, 0x00, 0x00, 0x18, 0x09,  // ........
                /* 0038 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0040 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0048 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0050 */  0x00, 0x0D, 0xFF, 0x0F, 0x00, 0x00, 0x00, 0x03,  // ........
                /* 0058 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0060 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0068 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0070 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x01,  // ........
                /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0C, 0x00,  // ........
                /* 0080 */  0xFF, 0xFF, 0x0D, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0088 */  0x00, 0x00, 0x02, 0x00, 0x87, 0x17, 0x00, 0x00,  // ........
                /* 0090 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0098 */  0x00, 0x02, 0xFF, 0xFF, 0xDF, 0xFF, 0x00, 0x00,  // ........
                /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0xE0, 0xFD, 0x87, 0x17,  // ........
                /* 00A8 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00B0 */  0x00, 0x00, 0x00, 0x02, 0xFF, 0xFF, 0xDF, 0xFF,  // ........
                /* 00B8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xE0, 0xFD,  // ........
                /* 00C0 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 00C8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00D0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00D8 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                /* 00E0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00E8 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00F0 */  0x00, 0x00, 0x00, 0x00, 0x8A, 0x2B, 0x00, 0x00,  // .....+..
                /* 00F8 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0100 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0108 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0110 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0118 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0120 */  0x00, 0x00, 0x79, 0x00                           // ..y.
            })
            Name (CRS2, Buffer (0xAE)
            {
                /* 0000 */  0x88, 0x0D, 0x00, 0x02, 0x0C, 0x00, 0x00, 0x00,  // ........
                /* 0008 */  0x80, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x80, 0x00,  // ........
                /* 0010 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0018 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0020 */  0x88, 0x0D, 0x00, 0x01, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0028 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0030 */  0x87, 0x17, 0x00, 0x00, 0x0C, 0x03, 0x00, 0x00,  // ........
                /* 0038 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0040 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0048 */  0x00, 0x00, 0x87, 0x17, 0x00, 0x00, 0x0C, 0x03,  // ........
                /* 0050 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80,  // ........
                /* 0058 */  0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0060 */  0x00, 0x00, 0x00, 0x80, 0x87, 0x17, 0x00, 0x00,  // ........
                /* 0068 */  0x0C, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0070 */  0x00, 0x80, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00,  // ........
                /* 0078 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x8A, 0x2B,  // .......+
                /* 0080 */  0x00, 0x00, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0088 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0090 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 0098 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00A0 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                /* 00A8 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (STAV) /* \_SB_.PCI0.STAV */
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                DBG8 = 0x25
                If (CPRB)
                {
                    CreateWordField (CRS1, 0x08, MIN0)
                    CreateWordField (CRS1, 0x0A, MAX0)
                    CreateWordField (CRS1, 0x0E, LEN0)
                    MIN0 = BRB /* \_SB_.PCI0.BRB_ */
                    LEN0 = BRL /* \_SB_.PCI0.BRL_ */
                    Local0 = LEN0 /* \_SB_.PCI0._CRS.LEN0 */
                    MAX0 = (MIN0 + Local0--)
                    CreateWordField (CRS1, 0x50, MIN1)
                    CreateWordField (CRS1, 0x52, MAX1)
                    CreateWordField (CRS1, 0x56, LEN1)
                    If ((IOB == 0x1000))
                    {
                        Local0 = IOL /* \_SB_.PCI0.IOL_ */
                        MAX1 = (IOB + Local0--)
                        Local0 = (MAX1 - MIN1) /* \_SB_.PCI0._CRS.MIN1 */
                        LEN1 = (Local0 + One)
                    }
                    Else
                    {
                        MIN1 = IOB /* \_SB_.PCI0.IOB_ */
                        LEN1 = IOL /* \_SB_.PCI0.IOL_ */
                        Local0 = LEN1 /* \_SB_.PCI0._CRS.LEN1 */
                        MAX1 = (MIN1 + Local0--)
                    }

                    If (((LVGA == One) || (LVGA == 0x55)))
                    {
                        If (VGAF)
                        {
                            CreateWordField (CRS1, 0x40, IMN1)
                            CreateWordField (CRS1, 0x42, IMX1)
                            CreateWordField (CRS1, 0x46, ILN1)
                            IMN1 = 0x03B0
                            IMX1 = 0x03DF
                            ILN1 = 0x30
                            CreateDWordField (CRS1, 0x62, VMN1)
                            CreateDWordField (CRS1, 0x66, VMX1)
                            CreateDWordField (CRS1, 0x6E, VLN1)
                            VMN1 = 0x000A0000
                            VMX1 = 0x000BFFFF
                            VLN1 = 0x00020000
                            VGAF = Zero
                        }
                    }

                    CreateDWordField (CRS1, 0x96, MIN3)
                    CreateDWordField (CRS1, 0x9A, MAX3)
                    CreateDWordField (CRS1, 0xA2, LEN3)
                    CreateDWordField (CRS1, 0xB0, MIN7)
                    CreateDWordField (CRS1, 0xB4, MAX7)
                    CreateDWordField (CRS1, 0xBC, LEN7)
                    CreateDWordField (CRS1, 0xCA, MIN9)
                    CreateDWordField (CRS1, 0xCE, MAX9)
                    CreateDWordField (CRS1, 0xD6, LEN9)
                    CreateDWordField (CRS1, 0xE4, MINA)
                    CreateDWordField (CRS1, 0xE8, MAXA)
                    CreateDWordField (CRS1, 0xF0, LENA)
                    Local7 = Zero
                    If ((NRSB != 0x00010000))
                    {
                        If ((RSTE == One))
                        {
                            Local7 = One
                            MIN3 = RSB0 /* \_SB_.PCI0.RSB0 */
                            LEN3 = RSS0 /* \_SB_.PCI0.RSS0 */
                            Local0 = (RSB0 + RSS0) /* \_SB_.PCI0.RSS0 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAX3 = Local0
                            MIN7 = RSB1 /* \_SB_.PCI0.RSB1 */
                            LEN7 = RSS1 /* \_SB_.PCI0.RSS1 */
                            Local0 = (RSB1 + RSS1) /* \_SB_.PCI0.RSS1 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAX7 = Local0
                            MIN9 = RSB2 /* \_SB_.PCI0.RSB2 */
                            LEN9 = RSS2 /* \_SB_.PCI0.RSS2 */
                            Local0 = (RSB2 + RSS2) /* \_SB_.PCI0.RSS2 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAX9 = Local0
                            MINA = RSB3 /* \_SB_.PCI0.RSB3 */
                            LENA = RSS3 /* \_SB_.PCI0.RSS3 */
                            Local0 = (RSB3 + RSS3) /* \_SB_.PCI0.RSS3 */
                            If ((Local0 != Zero))
                            {
                                Local0 -= One
                            }

                            MAXA = Local0
                        }
                    }

                    If ((Local7 == Zero))
                    {
                        Local0 = (MBB + MBL) /* \_SB_.PCI0.MBL_ */
                        If ((Local0 < NBTP))
                        {
                            MIN3 = MBB /* \_SB_.PCI0.MBB_ */
                            LEN3 = MBL /* \_SB_.PCI0.MBL_ */
                            Local0 = LEN3 /* \_SB_.PCI0._CRS.LEN3 */
                            MAX3 = (MIN3 + Local0--)
                            MIN7 = Zero
                            MAX7 = Zero
                            LEN7 = Zero
                        }
                        Else
                        {
                            MIN3 = MBB /* \_SB_.PCI0.MBB_ */
                            LEN3 = (NBTP - MBB)
                            Local0 = LEN3 /* \_SB_.PCI0._CRS.LEN3 */
                            MAX3 = (MIN3 + Local0--)
                            If (((MBL - LEN3) < 0x00200000))
                            {
                                MIN7 = Zero
                                MAX7 = Zero
                                LEN7 = Zero
                            }
                            Else
                            {
                                MIN7 = 0xFEE00000
                                Local0 = (0xFEE00000 - NBTP)
                                LEN7 = (MBL - Local0)
                                LEN7 = (LEN7 - LEN3)
                                Local0 = LEN7 /* \_SB_.PCI0._CRS.LEN7 */
                                MAX7 = (MIN7 + Local0--)
                            }
                        }
                    }

                    If (MAL)
                    {
                        CreateQWordField (CRS1, 0x0102, MN8)
                        CreateQWordField (CRS1, 0x010A, MX8)
                        CreateQWordField (CRS1, 0x011A, LN8)
                        MN8 = MAB /* \_SB_.PCI0.MAB_ */
                        LN8 = MAL /* \_SB_.PCI0.MAL_ */
                        MX8 = MAM /* \_SB_.PCI0.MAM_ */
                    }

                    DBG8 = 0x24
                    Return (CRS1) /* \_SB_.PCI0.CRS1 */
                }
                Else
                {
                    CreateWordField (CRS2, 0x08, MIN2)
                    CreateWordField (CRS2, 0x0A, MAX2)
                    CreateWordField (CRS2, 0x0E, LEN2)
                    MIN2 = BRB /* \_SB_.PCI0.BRB_ */
                    LEN2 = BRL /* \_SB_.PCI0.BRL_ */
                    Local1 = LEN2 /* \_SB_.PCI0._CRS.LEN2 */
                    MAX2 = (MIN2 + Local1--)
                    CreateWordField (CRS2, 0x28, MIN4)
                    CreateWordField (CRS2, 0x2A, MAX4)
                    CreateWordField (CRS2, 0x2E, LEN4)
                    MIN4 = IOB /* \_SB_.PCI0.IOB_ */
                    LEN4 = IOL /* \_SB_.PCI0.IOL_ */
                    Local1 = LEN4 /* \_SB_.PCI0._CRS.LEN4 */
                    MAX4 = (MIN4 + Local1--)
                    If (LVGA)
                    {
                        CreateWordField (CRS2, 0x18, IMN2)
                        CreateWordField (CRS2, 0x1A, IMX2)
                        CreateWordField (CRS2, 0x1E, ILN2)
                        IMN2 = 0x03B0
                        IMX2 = 0x03DF
                        ILN2 = 0x30
                        CreateDWordField (CRS2, 0x3A, VMN2)
                        CreateDWordField (CRS2, 0x3E, VMX2)
                        CreateDWordField (CRS2, 0x46, VLN2)
                        VMN2 = 0x000A0000
                        VMX2 = 0x000BFFFF
                        VLN2 = 0x00020000
                    }

                    CreateDWordField (CRS2, 0x54, MIN5)
                    CreateDWordField (CRS2, 0x58, MAX5)
                    CreateDWordField (CRS2, 0x60, LEN5)
                    MIN5 = MBB /* \_SB_.PCI0.MBB_ */
                    LEN5 = (NBTP - MBB)
                    Local1 = LEN5 /* \_SB_.PCI0._CRS.LEN5 */
                    MAX5 = (MIN5 + Local1--)
                    CreateDWordField (CRS2, 0x6E, MIN6)
                    CreateDWordField (CRS2, 0x72, MAX6)
                    CreateDWordField (CRS2, 0x7A, LEN6)
                    MIN6 = (NBTP + NBTS) /* \NBTS */
                    LEN6 = (MBL - NBTS)
                    LEN6 = (LEN6 - LEN5)
                    Local0 = LEN6 /* \_SB_.PCI0._CRS.LEN6 */
                    MAX6 = (MIN6 + Local0--)
                    If (MAL)
                    {
                        CreateQWordField (CRS2, 0x8C, MN9)
                        CreateQWordField (CRS2, 0x94, MX9)
                        CreateQWordField (CRS2, 0xA4, LN9)
                        MN9 = MAB /* \_SB_.PCI0.MAB_ */
                        LN9 = MAL /* \_SB_.PCI0.MAL_ */
                        MX9 = MAM /* \_SB_.PCI0.MAM_ */
                    }

                    DBG8 = 0x23
                    Return (CRS2) /* \_SB_.PCI0.CRS2 */
                }
            }

            Method (_OSC, 4, Serialized)  // _OSC: Operating System Capabilities
            {
                Name (SUPP, Zero)
                Name (CTRL, Zero)
                CreateDWordField (Arg3, Zero, CDW1)
                CreateDWordField (Arg3, 0x04, CDW2)
                CreateDWordField (Arg3, 0x08, CDW3)
                If ((Arg0 == ToUUID ("33db4d5b-1ff7-401c-9657-7441c03dd766") /* PCI Host Bridge Device */))
                {
                    SUPP = CDW2 /* \_SB_.PCI0._OSC.CDW2 */
                    CTRL = CDW3 /* \_SB_.PCI0._OSC.CDW3 */
                    If (((SUPP & 0x16) != 0x16))
                    {
                        CTRL &= 0x1E
                    }

                    If (!PEHP)
                    {
                        CTRL &= 0x1E
                    }

                    If (!SHPC)
                    {
                        CTRL &= 0x1D
                    }

                    If (!PEPM)
                    {
                        CTRL &= 0x1B
                    }

                    If (!PEER)
                    {
                        CTRL &= 0x15
                    }

                    If (!PECS)
                    {
                        CTRL &= 0x0F
                    }

                    If ((Arg1 != One))
                    {
                        CDW1 |= 0x08
                    }

                    If ((CDW3 != CTRL))
                    {
                        CDW1 |= 0x10
                    }

                    CDW3 = CTRL /* \_SB_.PCI0._OSC.CTRL */
                    Return (Arg3)
                }
                Else
                {
                    CDW1 |= 0x04
                    Return (Arg3)
                }
            }

            Mutex (NAPM, 0x00)
            Method (NAPE, 0, NotSerialized)
            {
                Acquire (NAPM, 0xFFFF)
                DBG8 = 0x11
                Local0 = (PEBS + 0xB8)
                OperationRegion (VARM, SystemMemory, Local0, 0x08)
                Field (VARM, DWordAcc, NoLock, Preserve)
                {
                    NAPX,   32, 
                    NAPD,   32
                }

                Local1 = NAPX /* \_SB_.PCI0.NAPE.NAPX */
                NAPX = 0x14300000
                Local0 = NAPD /* \_SB_.PCI0.NAPE.NAPD */
                Local0 &= 0xFFFFFFEF
                NAPD = Local0
                NAPX = Local1
                DBG8 = 0x12
                Release (NAPM)
            }

            Device (IOMA)
            {
                Name (_ADR, 0x02)  // _ADR: Address
            }

            Device (D002)
            {
                Name (_ADR, Zero)  // _ADR: Address
            }

            Device (GPP1)
            {
                Name (_ADR, 0x00010002)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR12) /* \_SB_.AR12 */
                    }

                    Return (PD12) /* \_SB_.PD12 */
                }

                Device (D004)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPP2)
            {
                Name (_ADR, 0x00010003)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR14) /* \_SB_.AR14 */
                    }

                    Return (PD14) /* \_SB_.PD14 */
                }

                Device (D006)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPP0)
            {
                Name (_ADR, 0x00010001)  // _ADR: Address
                Method (_PRW, 0, NotSerialized)  // _PRW: Power Resources for Wake
                {
                    Return (GPRW (0x08, 0x04))
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR10) /* \_SB_.AR10 */
                    }

                    Return (PD10) /* \_SB_.PD10 */
                }

                Device (D008)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPP3)
            {
                Name (_ADR, 0x00010004)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR16) /* \_SB_.AR16 */
                    }

                    Return (PD16) /* \_SB_.PD16 */
                }

                Device (D00A)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPP4)
            {
                Name (_ADR, 0x00010005)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR18) /* \_SB_.AR18 */
                    }

                    Return (PD18) /* \_SB_.PD18 */
                }

                Device (D00C)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }

                Device (D00E)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (BR0D)
            {
                Name (_ADR, 0x00010006)  // _ADR: Address
            }

            Device (GPP5)
            {
                Name (_ADR, 0x00020001)  // _ADR: Address
            }

            Device (GPP6)
            {
                Name (_ADR, 0x00020002)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR22) /* \_SB_.AR22 */
                    }

                    Return (PD22) /* \_SB_.PD22 */
                }

                Device (SD00)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                }
            }

            Device (GPP7)
            {
                Name (_ADR, 0x00020003)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR24) /* \_SB_.AR24 */
                    }

                    Return (PD24) /* \_SB_.PD24 */
                }

                Device (DEV0)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Method (RHRW, 0, NotSerialized)
                    {
                        Return (GPRW (0x0D, One))
                    }
                }
            }

            Device (GPP8)
            {
                Name (_ADR, 0x00020004)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR26) /* \_SB_.AR26 */
                    }

                    Return (PD26) /* \_SB_.PD26 */
                }

                Device (D013)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPP9)
            {
                Name (_ADR, 0x00020005)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR28) /* \_SB_.AR28 */
                    }

                    Return (PD28) /* \_SB_.PD28 */
                }

                Device (D015)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GPPA)
            {
                Name (_ADR, 0x00020006)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR2A) /* \_SB_.AR2A */
                    }

                    Return (PD2A) /* \_SB_.PD2A */
                }

                Device (D017)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GP11)
            {
                Name (_ADR, 0x00030001)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR30) /* \_SB_.AR30 */
                    }

                    Return (PD30) /* \_SB_.PD30 */
                }

                Device (D019)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GP12)
            {
                Name (_ADR, 0x00040001)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR60) /* \_SB_.AR60 */
                    }

                    Return (PD60) /* \_SB_.PD60 */
                }

                Device (D01B)
                {
                    Name (_ADR, 0xFF)  // _ADR: Address
                }
            }

            Device (GP17)
            {
                Name (_ADR, 0x00080001)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR90) /* \_SB_.AR90 */
                    }

                    Return (PD90) /* \_SB_.PD90 */
                }

                Device (VGA)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                    Name (AF7E, 0x80000001)
                    Name (DOSA, Zero)
                    Method (_DOS, 1, NotSerialized)  // _DOS: Disable Output Switching
                    {
                        DOSA = Arg0
                    }

                    Method (_DOD, 0, NotSerialized)  // _DOD: Display Output Devices
                    {
                        M460 ("PLA-ASL-\\_SB.PCI0.GP17.VGA._DOD\n", Zero, Zero, Zero, Zero, Zero, Zero)
                        Return (Package (0x07)
                        {
                            0x00010110, 
                            0x00010210, 
                            0x00010220, 
                            0x00010230, 
                            0x00010240, 
                            0x00031000, 
                            0x00032000
                        })
                    }

                    Device (LCD)
                    {
                        Name (_ADR, 0x0110)  // _ADR: Address
                        Name (BCLB, Package (0x34)
                        {
                            0x5A, 
                            0x3C, 
                            0x02, 
                            0x04, 
                            0x06, 
                            0x08, 
                            0x0A, 
                            0x0C, 
                            0x0E, 
                            0x10, 
                            0x12, 
                            0x14, 
                            0x16, 
                            0x18, 
                            0x1A, 
                            0x1C, 
                            0x1E, 
                            0x20, 
                            0x22, 
                            0x24, 
                            0x26, 
                            0x28, 
                            0x2A, 
                            0x2C, 
                            0x2E, 
                            0x30, 
                            0x32, 
                            0x34, 
                            0x36, 
                            0x38, 
                            0x3A, 
                            0x3C, 
                            0x3E, 
                            0x40, 
                            0x42, 
                            0x44, 
                            0x46, 
                            0x48, 
                            0x4A, 
                            0x4C, 
                            0x4E, 
                            0x50, 
                            0x52, 
                            0x54, 
                            0x56, 
                            0x58, 
                            0x5A, 
                            0x5C, 
                            0x5E, 
                            0x60, 
                            0x62, 
                            0x64
                        })
                        Method (_BCL, 0, NotSerialized)  // _BCL: Brightness Control Levels
                        {
                            M460 ("PLA-ASL-\\_SB.PCI0.GP17.VGA.LCD._BCL\n", Zero, Zero, Zero, Zero, Zero, Zero)
                            Return (BCLB) /* \_SB_.PCI0.GP17.VGA_.LCD_.BCLB */
                        }

                        Method (_BCM, 1, NotSerialized)  // _BCM: Brightness Control Method
                        {
                            If ((AF7E == 0x80000001))
                            {
                                M460 ("PLA-ASL-\\_SB.PCI0.GP17.VGA.LCD._BCM Arg0 = 0x%X\n", ToInteger (Arg0), Zero, Zero, Zero, Zero, Zero)
                                Divide ((Arg0 * 0xFF), 0x64, Local1, Local0)
                                AFN7 (Local0)
                            }
                        }
                    }
                }

                Device (HDAU)
                {
                    Name (_ADR, One)  // _ADR: Address
                }

                Device (ACP)
                {
                    Name (_ADR, 0x05)  // _ADR: Address
                }

                Device (AZAL)
                {
                    Name (_ADR, 0x06)  // _ADR: Address
                }

                Device (MP2C)
                {
                    Name (_ADR, 0x07)  // _ADR: Address
                }

                Device (XHC0)
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                }

                Device (XHC1)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                }

                Device (APSP)
                {
                    Name (_ADR, 0x02)  // _ADR: Address
                    Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                    Name (PSPB, 0xFD300000)
                    Name (PSPL, 0x00100000)
                    Name (_STA, 0x0F)  // _STA: Status
                    Name (CRS, Buffer (0x0E)
                    {
                        /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                        /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
                    })
                    Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                    {
                        CreateDWordField (CRS, 0x04, PBAS)
                        CreateDWordField (CRS, 0x08, PLEN)
                        PBAS = PSPB /* \_SB_.PCI0.GP17.APSP.PSPB */
                        PLEN = PSPL /* \_SB_.PCI0.GP17.APSP.PSPL */
                        Return (CRS) /* \_SB_.PCI0.GP17.APSP.CRS_ */
                    }
                }
            }

            Device (GP18)
            {
                Name (_ADR, 0x00080002)  // _ADR: Address
                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR92) /* \_SB_.AR92 */
                    }

                    Return (PD92) /* \_SB_.PD92 */
                }

                Device (IPU)
                {
                    Name (_ADR, One)  // _ADR: Address
                }
            }

            Device (GP19)
            {
                Name (_ADR, 0x00080003)  // _ADR: Address
                Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
                {
                    If ((Arg0 == ToUUID ("e5c937d0-3553-4d7a-9117-ea4d19c3434d") /* Device Labeling Interface */))
                    {
                        Switch (ToInteger (Arg2))
                        {
                            Case (Zero)
                            {
                                Return (Buffer (One)
                                {
                                     0xFF                                             // .
                                })
                            }
                            Case (0x05)
                            {
                                Return (Zero)
                            }
                            Default
                            {
                                Return (Zero)
                            }

                        }
                    }
                    Else
                    {
                        Return (Buffer (One)
                        {
                             0x00                                             // .
                        })
                    }
                }

                Method (_PRT, 0, NotSerialized)  // _PRT: PCI Routing Table
                {
                    If (PICM)
                    {
                        Return (AR94) /* \_SB_.AR94 */
                    }

                    Return (PD94) /* \_SB_.PD94 */
                }

                Device (XHC2)
                {
                    Name (_ADR, Zero)  // _ADR: Address
                }

                Device (XHC3)
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                }

                Device (XHC4)
                {
                    Name (_ADR, 0x04)  // _ADR: Address
                }

                Device (NHI0)
                {
                    Name (_ADR, 0x05)  // _ADR: Address
                }

                Device (NHI1)
                {
                    Name (_ADR, 0x06)  // _ADR: Address
                }

                Device (D036)
                {
                    Name (_ADR, 0x02)  // _ADR: Address
                }
            }

            Device (D02B)
            {
                Name (_ADR, 0x00140000)  // _ADR: Address
            }

            Device (SBRG)
            {
                Name (_ADR, 0x00140003)  // _ADR: Address
                Device (PIC)
                {
                    Name (_HID, EisaId ("PNP0000") /* 8259-compatible Programmable Interrupt Controller */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x15)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x20, 0x00, 0x20, 0x00, 0x00, 0x02,  // G. . ...
                        /* 0008 */  0x47, 0x01, 0xA0, 0x00, 0xA0, 0x00, 0x00, 0x02,  // G.......
                        /* 0010 */  0x22, 0x04, 0x00, 0x79, 0x00                     // "..y.
                    })
                }

                Device (DMAD)
                {
                    Name (_HID, EisaId ("PNP0200") /* PC-class DMA Controller */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x35)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x2A, 0x10, 0x04, 0x47, 0x01, 0x00, 0x00, 0x00,  // *..G....
                        /* 0008 */  0x00, 0x00, 0x10, 0x47, 0x01, 0x81, 0x00, 0x81,  // ...G....
                        /* 0010 */  0x00, 0x00, 0x03, 0x47, 0x01, 0x87, 0x00, 0x87,  // ...G....
                        /* 0018 */  0x00, 0x00, 0x01, 0x47, 0x01, 0x89, 0x00, 0x89,  // ...G....
                        /* 0020 */  0x00, 0x00, 0x03, 0x47, 0x01, 0x8F, 0x00, 0x8F,  // ...G....
                        /* 0028 */  0x00, 0x00, 0x01, 0x47, 0x01, 0xC0, 0x00, 0xC0,  // ...G....
                        /* 0030 */  0x00, 0x00, 0x20, 0x79, 0x00                     // .. y.
                    })
                }

                Device (TMR)
                {
                    Name (_HID, EisaId ("PNP0100") /* PC-class System Timer */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x0D)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x40, 0x00, 0x40, 0x00, 0x00, 0x04,  // G.@.@...
                        /* 0008 */  0x22, 0x01, 0x00, 0x79, 0x00                     // "..y.
                    })
                }

                Device (RTC0)
                {
                    Name (_HID, EisaId ("PNP0B00") /* AT Real-Time Clock */)  // _HID: Hardware ID
                    Name (BUF0, Buffer (0x0A)
                    {
                        /* 0000 */  0x47, 0x01, 0x70, 0x00, 0x70, 0x00, 0x00, 0x02,  // G.p.p...
                        /* 0008 */  0x79, 0x00                                       // y.
                    })
                    Name (BUF1, Buffer (0x0D)
                    {
                        /* 0000 */  0x47, 0x01, 0x70, 0x00, 0x70, 0x00, 0x00, 0x02,  // G.p.p...
                        /* 0008 */  0x22, 0x00, 0x01, 0x79, 0x00                     // "..y.
                    })
                    Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
                    {
                        If ((HPEN == One))
                        {
                            Return (BUF0) /* \_SB_.PCI0.SBRG.RTC0.BUF0 */
                        }

                        Return (BUF1) /* \_SB_.PCI0.SBRG.RTC0.BUF1 */
                    }
                }

                Device (SPKR)
                {
                    Name (_HID, EisaId ("PNP0800") /* Microsoft Sound System Compatible Device */)  // _HID: Hardware ID
                    Name (_CRS, Buffer (0x0A)  // _CRS: Current Resource Settings
                    {
                        /* 0000 */  0x47, 0x01, 0x61, 0x00, 0x61, 0x00, 0x00, 0x01,  // G.a.a...
                        /* 0008 */  0x79, 0x00                                       // y.
                    })
                }

                OperationRegion (SMI0, SystemIO, SMIO, One)
                Field (SMI0, ByteAcc, NoLock, Preserve)
                {
                    SMIC,   8
                }

                Scope (\_SB)
                {
                    Scope (PCI0)
                    {
                        Device (S900)
                        {
                            Name (_HID, EisaId ("PNP0C02") /* PNP Motherboard Resources */)  // _HID: Hardware ID
                            Name (_UID, 0x0700)  // _UID: Unique ID
                            Name (_STA, 0x0F)  // _STA: Status
                            Name (CRS, Buffer (0x017A)
                            {
                                /* 0000 */  0x47, 0x01, 0x10, 0x00, 0x10, 0x00, 0x00, 0x10,  // G.......
                                /* 0008 */  0x47, 0x01, 0x22, 0x00, 0x22, 0x00, 0x00, 0x1E,  // G."."...
                                /* 0010 */  0x47, 0x01, 0x63, 0x00, 0x63, 0x00, 0x00, 0x01,  // G.c.c...
                                /* 0018 */  0x47, 0x01, 0x65, 0x00, 0x65, 0x00, 0x00, 0x01,  // G.e.e...
                                /* 0020 */  0x47, 0x01, 0x67, 0x00, 0x67, 0x00, 0x00, 0x09,  // G.g.g...
                                /* 0028 */  0x47, 0x01, 0x72, 0x00, 0x72, 0x00, 0x00, 0x0E,  // G.r.r...
                                /* 0030 */  0x47, 0x01, 0x80, 0x00, 0x80, 0x00, 0x00, 0x01,  // G.......
                                /* 0038 */  0x47, 0x01, 0x84, 0x00, 0x84, 0x00, 0x00, 0x03,  // G.......
                                /* 0040 */  0x47, 0x01, 0x88, 0x00, 0x88, 0x00, 0x00, 0x01,  // G.......
                                /* 0048 */  0x47, 0x01, 0x8C, 0x00, 0x8C, 0x00, 0x00, 0x03,  // G.......
                                /* 0050 */  0x47, 0x01, 0x90, 0x00, 0x90, 0x00, 0x00, 0x10,  // G.......
                                /* 0058 */  0x47, 0x01, 0xA2, 0x00, 0xA2, 0x00, 0x00, 0x1E,  // G.......
                                /* 0060 */  0x47, 0x01, 0xB1, 0x00, 0xB1, 0x00, 0x00, 0x01,  // G.......
                                /* 0068 */  0x47, 0x01, 0xE0, 0x00, 0xE0, 0x00, 0x00, 0x10,  // G.......
                                /* 0070 */  0x47, 0x01, 0xD0, 0x04, 0xD0, 0x04, 0x00, 0x02,  // G.......
                                /* 0078 */  0x47, 0x01, 0x0B, 0x04, 0x0B, 0x04, 0x00, 0x01,  // G.......
                                /* 0080 */  0x47, 0x01, 0xD6, 0x04, 0xD6, 0x04, 0x00, 0x01,  // G.......
                                /* 0088 */  0x47, 0x01, 0x00, 0x0C, 0x00, 0x0C, 0x00, 0x02,  // G.......
                                /* 0090 */  0x47, 0x01, 0x14, 0x0C, 0x14, 0x0C, 0x00, 0x01,  // G.......
                                /* 0098 */  0x47, 0x01, 0x50, 0x0C, 0x50, 0x0C, 0x00, 0x02,  // G.P.P...
                                /* 00A0 */  0x47, 0x01, 0x52, 0x0C, 0x52, 0x0C, 0x00, 0x01,  // G.R.R...
                                /* 00A8 */  0x47, 0x01, 0x6C, 0x0C, 0x6C, 0x0C, 0x00, 0x01,  // G.l.l...
                                /* 00B0 */  0x47, 0x01, 0x6F, 0x0C, 0x6F, 0x0C, 0x00, 0x01,  // G.o.o...
                                /* 00B8 */  0x47, 0x01, 0xD0, 0x0C, 0xD0, 0x0C, 0x00, 0x02,  // G.......
                                /* 00C0 */  0x47, 0x01, 0xD2, 0x0C, 0xD2, 0x0C, 0x00, 0x02,  // G.......
                                /* 00C8 */  0x47, 0x01, 0xD4, 0x0C, 0xD4, 0x0C, 0x00, 0x02,  // G.......
                                /* 00D0 */  0x47, 0x01, 0xD6, 0x0C, 0xD6, 0x0C, 0x00, 0x02,  // G.......
                                /* 00D8 */  0x47, 0x01, 0xD8, 0x0C, 0xD8, 0x0C, 0x00, 0x08,  // G.......
                                /* 00E0 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // G.......
                                /* 00E8 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // G.......
                                /* 00F0 */  0x47, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // G.......
                                /* 00F8 */  0x47, 0x01, 0x00, 0x09, 0x00, 0x09, 0x00, 0x10,  // G.......
                                /* 0100 */  0x47, 0x01, 0x10, 0x09, 0x10, 0x09, 0x00, 0x10,  // G.......
                                /* 0108 */  0x47, 0x01, 0x60, 0x00, 0x60, 0x00, 0x00, 0x00,  // G.`.`...
                                /* 0110 */  0x47, 0x01, 0x64, 0x00, 0x64, 0x00, 0x00, 0x00,  // G.d.d...
                                /* 0118 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0120 */  0x00, 0x00, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0128 */  0x00, 0x10, 0xC0, 0xFE, 0x00, 0x10, 0x00, 0x00,  // ........
                                /* 0130 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xDC, 0xFE,  // ........
                                /* 0138 */  0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0140 */  0x00, 0x00, 0xE0, 0xFE, 0x00, 0x10, 0x00, 0x00,  // ........
                                /* 0148 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD8, 0xFE,  // ........
                                /* 0150 */  0x00, 0x00, 0x01, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0158 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0160 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0168 */  0x00, 0x00, 0x00, 0x00, 0x86, 0x09, 0x00, 0x01,  // ........
                                /* 0170 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
                                /* 0178 */  0x79, 0x00                                       // y.
                            })
                            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
                            {
                                CreateWordField (CRS, 0xE2, PBB)
                                CreateWordField (CRS, 0xE4, PBH)
                                CreateByteField (CRS, 0xE7, PML)
                                PBB = PMBS /* \PMBS */
                                PBH = PMBS /* \PMBS */
                                PML = PMLN /* \PMLN */
                                If (SMBB)
                                {
                                    CreateWordField (CRS, 0xF2, SMB1)
                                    CreateWordField (CRS, 0xF4, SMH1)
                                    CreateByteField (CRS, 0xF7, SML1)
                                    SMB1 = SMBB /* \SMBB */
                                    SMH1 = SMBB /* \SMBB */
                                    SML1 = SMBL /* \SMBL */
                                    CreateWordField (CRS, 0xEA, SMBZ)
                                    CreateWordField (CRS, 0xEC, SMH0)
                                    CreateByteField (CRS, 0xEF, SML0)
                                    SMBZ = SMB0 /* \SMB0 */
                                    SMH0 = SMB0 /* \SMB0 */
                                    SML0 = SMBM /* \SMBM */
                                }

                                If (APCB)
                                {
                                    CreateDWordField (CRS, 0x011C, APB)
                                    CreateDWordField (CRS, 0x0120, APL)
                                    APB = APCB /* \APCB */
                                    APL = APCL /* \APCL */
                                }

                                CreateDWordField (CRS, 0x0158, SPIB)
                                CreateDWordField (CRS, 0x015C, SPIL)
                                SPIB = 0xFEC10000
                                SPIL = 0x1000
                                If (WDTB)
                                {
                                    CreateDWordField (CRS, 0x0164, WDTB)
                                    CreateDWordField (CRS, 0x0168, WDTL)
                                    WDTB = \WDTB
                                    WDTL = \WDTL
                                }

                                CreateDWordField (CRS, 0x0170, ROMB)
                                CreateDWordField (CRS, 0x0174, ROML)
                                ROMB = 0xFF000000
                                ROML = 0x01000000
                                Return (CRS) /* \_SB_.PCI0.S900.CRS_ */
                            }
                        }
                    }
                }

                Scope (\_SB)
                {
                    Scope (PCI0)
                    {
                        Scope (SBRG)
                        {
                            Method (RRIO, 4, NotSerialized)
                            {
                                Debug = "RRIO"
                            }

                            Method (RDMA, 3, NotSerialized)
                            {
                                Debug = "rDMA"
                            }
                        }
                    }
                }
            }

            Device (D02E)
            {
                Name (_ADR, 0x00140006)  // _ADR: Address
            }
        }
    }

    Scope (_GPE)
    {
        Method (XL08, 0, NotSerialized)
        {
            Notify (\_SB.PCI0.GPP0, 0x02) // Device Wake
            Notify (\_SB.PWRB, 0x02) // Device Wake
        }

        Method (XL0D, 0, NotSerialized)
        {
            Notify (\_SB.PCI0.GPP7.DEV0, 0x02) // Device Wake
            Notify (\_SB.PWRB, 0x02) // Device Wake
        }
    }

    Scope (_SB)
    {
        Device (PWRB)
        {
            Name (_HID, EisaId ("PNP0C0C") /* Power Button Device */)  // _HID: Hardware ID
            Name (_UID, 0xAA)  // _UID: Unique ID
            Name (_STA, 0x0B)  // _STA: Status
        }
    }

    Name (_S0, Package (0x04)  // _S0_: S0 System State
    {
        Zero, 
        Zero, 
        Zero, 
        Zero
    })
    Name (_S4, Package (0x04)  // _S4_: S4 System State
    {
        0x04, 
        Zero, 
        Zero, 
        Zero
    })
    Name (_S5, Package (0x04)  // _S5_: S5 System State
    {
        0x05, 
        Zero, 
        Zero, 
        Zero
    })
    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        If (Arg0)
        {
            \_SB.TPM.TPTS (Arg0)
            SPTS (Arg0)
            MPTS (Arg0)
            \_SB.PCI0.NPTS (Arg0)
        }
    }

    Method (_WAK, 1, NotSerialized)  // _WAK: Wake
    {
        DBG8 = (Arg0 << 0x04)
        \_SB.PCI0.NWAK (Arg0)
        If (((Arg0 == 0x03) || (Arg0 == 0x04)))
        {
            If ((PICM != Zero))
            {
                \_SB.PCI0.NAPE ()
            }
        }

        MWAK (Arg0)
        DBG8 = (Arg0 << 0x04)
        SWAK (Arg0)
        Return (WAKP) /* \WAKP */
    }

    Scope (_SB)
    {
        OperationRegion (PIRQ, SystemIO, 0x0C00, 0x02)
        Field (PIRQ, ByteAcc, NoLock, Preserve)
        {
            PIDX,   8, 
            PDAT,   8
        }

        IndexField (PIDX, PDAT, ByteAcc, NoLock, Preserve)
        {
            PIRA,   8, 
            PIRB,   8, 
            PIRC,   8, 
            PIRD,   8, 
            PIRE,   8, 
            PIRF,   8, 
            PIRG,   8, 
            PIRH,   8, 
            Offset (0x0C), 
            SIRA,   8, 
            SIRB,   8, 
            SIRC,   8, 
            SIRD,   8, 
            PIRS,   8, 
            Offset (0x13), 
            HDAD,   8, 
            Offset (0x17), 
            SDCL,   8, 
            Offset (0x1A), 
            SDIO,   8, 
            Offset (0x30), 
            USB1,   8, 
            Offset (0x34), 
            USB3,   8, 
            Offset (0x41), 
            SATA,   8, 
            Offset (0x62), 
            GIOC,   8, 
            Offset (0x70), 
            I2C0,   8, 
            I2C1,   8, 
            I2C2,   8, 
            I2C3,   8, 
            URT0,   8, 
            URT1,   8, 
            Offset (0x80), 
            AIRA,   8, 
            AIRB,   8, 
            AIRC,   8, 
            AIRD,   8, 
            AIRE,   8, 
            AIRF,   8, 
            AIRG,   8, 
            AIRH,   8
        }

        OperationRegion (KBDD, SystemIO, 0x64, One)
        Field (KBDD, ByteAcc, NoLock, Preserve)
        {
            PD64,   8
        }

        Method (DSPI, 0, NotSerialized)
        {
            INTA (0x1F)
            INTB (0x1F)
            INTC (0x1F)
            INTD (0x1F)
            Local1 = PD64 /* \_SB_.PD64 */
            PIRE = 0x1F
            PIRF = 0x1F
            PIRG = 0x1F
            PIRH = 0x1F
            Local1 = PD64 /* \_SB_.PD64 */
            AIRA = 0x10
            AIRB = 0x11
            AIRC = 0x12
            AIRD = 0x13
            AIRE = 0x14
            AIRF = 0x15
            AIRG = 0x16
            AIRH = 0x17
        }

        Method (INTA, 1, NotSerialized)
        {
            PIRA = Arg0
            HDAD = Arg0
        }

        Method (INTB, 1, NotSerialized)
        {
            PIRB = Arg0
        }

        Method (INTC, 1, NotSerialized)
        {
            PIRC = Arg0
            USB1 = Arg0
            USB3 = Arg0
        }

        Method (INTD, 1, NotSerialized)
        {
            PIRD = Arg0
            SATA = Arg0
        }

        Name (BUFA, Buffer (0x06)
        {
             0x23, 0x00, 0x80, 0x18, 0x79, 0x00               // #...y.
        })
        Name (IPRA, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Name (IPRB, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Name (IPRC, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Name (IPRD, Buffer (0x06)
        {
             0x23, 0x20, 0x0C, 0x18, 0x79, 0x00               // # ..y.
        })
        Device (LNKA)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRA)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSA) /* \_SB_.PRSA */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTA (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRA) /* \_SB_.PIRA */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTA (Local0)
            }
        }

        Device (LNKB)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRB)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSB) /* \_SB_.PRSB */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTB (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRB) /* \_SB_.PIRB */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTB (Local0)
            }
        }

        Device (LNKC)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRC)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSC) /* \_SB_.PRSC */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTC (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRC) /* \_SB_.PIRC */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTC (Local0)
            }
        }

        Device (LNKD)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRD)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSD) /* \_SB_.PRSD */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                INTD (0x1F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRD) /* \_SB_.PIRD */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                INTD (Local0)
            }
        }

        Device (LNKE)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x05)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRE)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSE) /* \_SB_.PRSE */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRE = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRE) /* \_SB_.PIRE */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (PIRE, Local0)
                Local0--
                PIRE = Local0
            }
        }

        Device (LNKF)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x06)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRF)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSF) /* \_SB_.PRSF */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRF = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRF) /* \_SB_.PIRF */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRF = Local0
            }
        }

        Device (LNKG)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x07)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRG)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSG) /* \_SB_.PRSG */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRG = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRG) /* \_SB_.PIRG */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRG = Local0
            }
        }

        Device (LNKH)
        {
            Name (_HID, EisaId ("PNP0C0F") /* PCI Interrupt Link Device */)  // _HID: Hardware ID
            Name (_UID, 0x08)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (PIRH)
                {
                    Return (0x0B)
                }
                Else
                {
                    Return (0x09)
                }
            }

            Method (_PRS, 0, NotSerialized)  // _PRS: Possible Resource Settings
            {
                Return (PRSH) /* \_SB_.PRSH */
            }

            Method (_DIS, 0, NotSerialized)  // _DIS: Disable Device
            {
                PIRH = 0x1F
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                CreateWordField (BUFA, One, IRQX)
                IRQX = (One << PIRH) /* \_SB_.PIRH */
                Return (BUFA) /* \_SB_.BUFA */
            }

            Method (_SRS, 1, NotSerialized)  // _SRS: Set Resource Settings
            {
                CreateWordField (Arg0, One, IRA)
                FindSetRightBit (IRA, Local0)
                Local0--
                PIRH = Local0
            }
        }
    }

    Name (OSTB, Ones)
    Name (TPOS, Zero)
    Name (LINX, Zero)
    Name (OSSP, Zero)
    Method (SEQL, 2, Serialized)
    {
        Local0 = SizeOf (Arg0)
        Local1 = SizeOf (Arg1)
        If ((Local0 != Local1))
        {
            Return (Zero)
        }

        Name (BUF0, Buffer (Local0){})
        BUF0 = Arg0
        Name (BUF1, Buffer (Local0){})
        BUF1 = Arg1
        Local2 = Zero
        While ((Local2 < Local0))
        {
            Local3 = DerefOf (BUF0 [Local2])
            Local4 = DerefOf (BUF1 [Local2])
            If ((Local3 != Local4))
            {
                Return (Zero)
            }

            Local2++
        }

        Return (One)
    }

    Method (OSTP, 0, NotSerialized)
    {
        If ((OSTB == Ones))
        {
            If (CondRefOf (\_OSI, Local0))
            {
                OSTB = Zero
                TPOS = Zero
                If (_OSI ("Windows 2001"))
                {
                    OSTB = 0x08
                    TPOS = 0x08
                }

                If (_OSI ("Windows 2001.1"))
                {
                    OSTB = 0x20
                    TPOS = 0x20
                }

                If (_OSI ("Windows 2001 SP1"))
                {
                    OSTB = 0x10
                    TPOS = 0x10
                }

                If (_OSI ("Windows 2001 SP2"))
                {
                    OSTB = 0x11
                    TPOS = 0x11
                }

                If (_OSI ("Windows 2001 SP3"))
                {
                    OSTB = 0x12
                    TPOS = 0x12
                }

                If (_OSI ("Windows 2006"))
                {
                    OSTB = 0x40
                    TPOS = 0x40
                }

                If (_OSI ("Windows 2006 SP1"))
                {
                    OSTB = 0x41
                    TPOS = 0x41
                    OSSP = One
                }

                If (_OSI ("Windows 2009"))
                {
                    OSSP = One
                    OSTB = 0x50
                    TPOS = 0x50
                }

                If (_OSI ("Windows 2012"))
                {
                    OSSP = One
                    OSTB = 0x60
                    TPOS = 0x60
                }

                If (_OSI ("Windows 2013"))
                {
                    OSSP = One
                    OSTB = 0x61
                    TPOS = 0x61
                }

                If (_OSI ("Windows 2015"))
                {
                    OSSP = One
                    OSTB = 0x70
                    TPOS = 0x70
                }

                If (_OSI ("Linux"))
                {
                    LINX = One
                    OSTB = 0x80
                    TPOS = 0x80
                }
            }
            ElseIf (CondRefOf (\_OS, Local0))
            {
                If (SEQL (_OS, "Microsoft Windows"))
                {
                    OSTB = One
                    TPOS = One
                }
                ElseIf (SEQL (_OS, "Microsoft WindowsME: Millennium Edition"))
                {
                    OSTB = 0x02
                    TPOS = 0x02
                }
                ElseIf (SEQL (_OS, "Microsoft Windows NT"))
                {
                    OSTB = 0x04
                    TPOS = 0x04
                }
                Else
                {
                    OSTB = Zero
                    TPOS = Zero
                }
            }
            Else
            {
                OSTB = Zero
                TPOS = Zero
            }
        }

        Return (OSTB) /* \OSTB */
    }

    Scope (_SB.PCI0)
    {
        Method (_INI, 0, NotSerialized)  // _INI: Initialize
        {
            If ((PICM != Zero))
            {
                DSPI ()
                NAPE ()
            }

            OSTP ()
            OSFL ()
        }
    }

    Device (HPET)
    {
        Name (_HID, EisaId ("PNP0103") /* HPET System Timer */)  // _HID: Hardware ID
        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((HPEN == One))
            {
                If ((OSVR >= 0x0C))
                {
                    Return (0x0F)
                }

                HPEN = Zero
                Return (One)
            }

            Return (One)
        }

        Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
        {
            Name (BUF0, Buffer (0x14)
            {
                /* 0000 */  0x22, 0x01, 0x00, 0x22, 0x00, 0x01, 0x86, 0x09,  // ".."....
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0xD0, 0xFE, 0x00, 0x04,  // ........
                /* 0010 */  0x00, 0x00, 0x79, 0x00                           // ..y.
            })
            Return (BUF0) /* \HPET._CRS.BUF0 */
        }
    }

    Name (TSOS, 0x75)
    Name (UR0I, 0x03)
    Name (UR1I, 0x0E)
    Name (UR2I, 0x05)
    Name (UR3I, 0x0F)
    Name (UR4I, 0x0D)
    Name (IC0I, 0x0A)
    Name (IC1I, 0x0B)
    Name (IC2I, 0x04)
    Name (IC3I, 0x06)
    Name (IC4I, 0x0E)
    Name (HPTI, 0x0F)
    Name (HCOR, 0x0F)
    If (CondRefOf (\_OSI))
    {
        If (_OSI ("Windows 2009"))
        {
            TSOS = 0x50
        }

        If (_OSI ("Windows 2015"))
        {
            TSOS = 0x70
        }
    }

    Scope (_SB)
    {
        OperationRegion (SMIC, SystemMemory, 0xFED80000, 0x00800000)
        Field (SMIC, ByteAcc, NoLock, Preserve)
        {
            Offset (0x36A), 
            SMIB,   8
        }

        OperationRegion (SSMI, SystemIO, SMIB, 0x02)
        Field (SSMI, AnyAcc, NoLock, Preserve)
        {
            SMIW,   16
        }

        OperationRegion (ECMC, SystemIO, 0x72, 0x02)
        Field (ECMC, AnyAcc, NoLock, Preserve)
        {
            ECMI,   8, 
            ECMD,   8
        }

        IndexField (ECMI, ECMD, ByteAcc, NoLock, Preserve)
        {
            Offset (0x08), 
            FRTB,   32
        }

        OperationRegion (FRTP, SystemMemory, FRTB, 0x0100)
        Field (FRTP, AnyAcc, NoLock, Preserve)
        {
            PEBA,   32, 
            Offset (0x04), 
                ,   5, 
            IC0E,   1, 
            IC1E,   1, 
            IC2E,   1, 
            IC3E,   1, 
            IC4E,   1, 
            IC5E,   1, 
            UT0E,   1, 
            UT1E,   1, 
            I31E,   1, 
            I32E,   1, 
            I33E,   1, 
            UT2E,   1, 
                ,   1, 
            EMMD,   2, 
            UT4E,   1, 
            I30E,   1, 
                ,   1, 
            XHCE,   1, 
                ,   1, 
                ,   1, 
            UT3E,   1, 
            ESPI,   1, 
            EMME,   1, 
            HFPE,   1, 
            HD0E,   1, 
            HD2E,   1, 
            Offset (0x08), 
            PCEF,   1, 
                ,   4, 
            IC0D,   1, 
            IC1D,   1, 
            IC2D,   1, 
            IC3D,   1, 
            IC4D,   1, 
            IC5D,   1, 
            UT0D,   1, 
            UT1D,   1, 
            I31D,   1, 
            I32D,   1, 
            I33D,   1, 
            UT2D,   1, 
                ,   1, 
            EHCD,   1, 
                ,   1, 
            UT4D,   1, 
            I30D,   1, 
                ,   1, 
            XHCD,   1, 
            SD_D,   1, 
                ,   1, 
            UT3D,   1, 
                ,   1, 
            EMD3,   1, 
                ,   1, 
            US4D,   1, 
            S03D,   1, 
            UT0O,   1, 
            UT1O,   1, 
            UT2O,   1, 
            UT3O,   1, 
            Offset (0x1C), 
            I30M,   1, 
            I31M,   1, 
            I32M,   1, 
            I33M,   1, 
            Offset (0x2D), 
            UT0I,   1, 
            UT1I,   1, 
            UT2I,   1, 
            UT3I,   1, 
            UT4I,   1, 
            Offset (0x2E), 
            UL0I,   1, 
            UL1I,   1, 
            UL2I,   1, 
            UL3I,   1
        }

        OperationRegion (FCFG, SystemMemory, PEBA, 0x01000000)
        Field (FCFG, DWordAcc, NoLock, Preserve)
        {
            Offset (0xA3078), 
                ,   2, 
            LDQ0,   1, 
            Offset (0xA30CB), 
                ,   7, 
            AUSS,   1
        }

        OperationRegion (IOMX, SystemMemory, 0xFED80D00, 0x0100)
        Field (IOMX, AnyAcc, NoLock, Preserve)
        {
            Offset (0x15), 
            IM15,   8, 
            Offset (0x16), 
            IM16,   8, 
            Offset (0x1F), 
            IM1F,   8, 
            Offset (0x20), 
            IM20,   8, 
            Offset (0x44), 
            IM44,   8, 
            Offset (0x46), 
            IM46,   8, 
            Offset (0x4A), 
            IM4A,   8, 
            Offset (0x4B), 
            IM4B,   8, 
            Offset (0x57), 
            IM57,   8, 
            Offset (0x58), 
            IM58,   8, 
            Offset (0x68), 
            IM68,   8, 
            Offset (0x69), 
            IM69,   8, 
            Offset (0x6A), 
            IM6A,   8, 
            Offset (0x6B), 
            IM6B,   8, 
            Offset (0x6D), 
            IM6D,   8
        }

        OperationRegion (FACR, SystemMemory, 0xFED81E00, 0x0100)
        Field (FACR, AnyAcc, NoLock, Preserve)
        {
            Offset (0x80), 
                ,   28, 
            RD28,   1, 
                ,   1, 
            RQTY,   1, 
            Offset (0x84), 
                ,   28, 
            SD28,   1, 
                ,   1, 
            Offset (0xA0), 
            PG1A,   1
        }

        OperationRegion (LUIE, SystemMemory, 0xFEDC0020, 0x04)
        Field (LUIE, AnyAcc, NoLock, Preserve)
        {
            IER0,   1, 
            IER1,   1, 
            IER2,   1, 
            IER3,   1, 
            UOL0,   1, 
            UOL1,   1, 
            UOL2,   1, 
            UOL3,   1, 
            WUR0,   2, 
            WUR1,   2, 
            WUR2,   2, 
            WUR3,   2
        }

        Method (FRUI, 1, Serialized)
        {
            If ((Arg0 == Zero))
            {
                Return (IUA0) /* \_SB_.IUA0 */
            }
            ElseIf ((Arg0 == One))
            {
                Return (IUA1) /* \_SB_.IUA1 */
            }
            ElseIf ((Arg0 == 0x02))
            {
                Return (IUA2) /* \_SB_.IUA2 */
            }
            ElseIf ((Arg0 == 0x03))
            {
                Return (IUA3) /* \_SB_.IUA3 */
            }
            Else
            {
                Return (0x03)
            }
        }

        Method (FUIO, 1, Serialized)
        {
            If ((IER0 == One))
            {
                If ((WUR0 == Arg0))
                {
                    Return (Zero)
                }
            }

            If ((IER1 == One))
            {
                If ((WUR1 == Arg0))
                {
                    Return (One)
                }
            }

            If ((IER2 == One))
            {
                If ((WUR2 == Arg0))
                {
                    Return (0x02)
                }
            }

            If ((IER3 == One))
            {
                If ((WUR3 == Arg0))
                {
                    Return (0x03)
                }
            }

            Return (0x0F)
        }

        Method (SRAD, 2, Serialized)
        {
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            ADIS = One
            ADSR = Zero
            Stall (Arg1)
            ADSR = One
            ADIS = Zero
            Stall (Arg1)
        }

        Method (DSAD, 2, Serialized)
        {
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            If ((Arg1 != ADTD))
            {
                If ((Arg1 == Zero))
                {
                    ADTD = Zero
                    ADPD = One
                    Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    While ((Local0 != 0x07))
                    {
                        Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    }
                }

                If ((Arg1 == 0x03))
                {
                    ADPD = Zero
                    Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    While ((Local0 != Zero))
                    {
                        Local0 = ADDS /* \_SB_.DSAD.ADDS */
                    }

                    ADTD = 0x03
                }
            }
        }

        Method (HSAD, 2, Serialized)
        {
            Local3 = (One << Arg0)
            Local0 = (Arg0 << One)
            Local0 += 0xFED81E40
            OperationRegion (ADCR, SystemMemory, Local0, 0x02)
            Field (ADCR, ByteAcc, NoLock, Preserve)
            {
                ADTD,   2, 
                ADPS,   1, 
                ADPD,   1, 
                ADSO,   1, 
                ADSC,   1, 
                ADSR,   1, 
                ADIS,   1, 
                ADDS,   3
            }

            If ((Arg1 != ADTD))
            {
                If ((Arg1 == Zero))
                {
                    PG1A = One
                    ADTD = Zero
                    ADPD = One
                    Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    While ((Local0 != 0x07))
                    {
                        Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    }

                    RQTY = One
                    RD28 = One
                    Local0 = SD28 /* \_SB_.SD28 */
                    While (!Local0)
                    {
                        Local0 = SD28 /* \_SB_.SD28 */
                    }
                }

                If ((Arg1 == 0x03))
                {
                    RQTY = Zero
                    RD28 = One
                    Local0 = SD28 /* \_SB_.SD28 */
                    While (Local0)
                    {
                        Local0 = SD28 /* \_SB_.SD28 */
                    }

                    ADPD = Zero
                    Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    While ((Local0 != Zero))
                    {
                        Local0 = ADDS /* \_SB_.HSAD.ADDS */
                    }

                    ADTD = 0x03
                    PG1A = Zero
                }
            }
        }

        OperationRegion (FPIC, SystemIO, 0x0C00, 0x02)
        Field (FPIC, AnyAcc, NoLock, Preserve)
        {
            FPII,   8, 
            FPID,   8
        }

        IndexField (FPII, FPID, ByteAcc, NoLock, Preserve)
        {
            Offset (0xF4), 
            IUA0,   8, 
            Offset (0xF5), 
            IUA1,   8, 
            Offset (0xF6), 
            IIF6,   8, 
            Offset (0xF7), 
            IIF7,   8, 
            Offset (0xF8), 
            IUA2,   8, 
            Offset (0xF9), 
            IUA3,   8
        }

        Device (HFP1)
        {
            Name (_HID, "AMDI0060")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HFPE)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x0E)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x10, 0xC1, 0xFE,  // ........
                    /* 0008 */  0x00, 0x01, 0x00, 0x00, 0x79, 0x00               // ....y.
                })
                Return (RBUF) /* \_SB_.HFP1._CRS.RBUF */
            }
        }

        Device (HID0)
        {
            Name (_HID, "AMDI0063")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HD0E)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x31)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x30, 0xC1, 0xFE,  // .....0..
                    /* 0008 */  0x00, 0x02, 0x00, 0x00, 0x8C, 0x20, 0x00, 0x01,  // ..... ..
                    /* 0010 */  0x00, 0x01, 0x00, 0x19, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0018 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0020 */  0x00, 0x00, 0x00, 0xAB, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
                    /* 0028 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
                    /* 0030 */  0x00                                             // .
                })
                Return (RBUF) /* \_SB_.HID0._CRS.RBUF */
            }
        }

        Device (HID2)
        {
            Name (_HID, "AMDI0063")  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (HD2E)
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x31)
                {
                    /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x20, 0xC1, 0xFE,  // ..... ..
                    /* 0008 */  0x00, 0x02, 0x00, 0x00, 0x8C, 0x20, 0x00, 0x01,  // ..... ..
                    /* 0010 */  0x00, 0x01, 0x00, 0x19, 0x00, 0x03, 0x00, 0x00,  // ........
                    /* 0018 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
                    /* 0020 */  0x00, 0x00, 0x00, 0xAB, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
                    /* 0028 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
                    /* 0030 */  0x00                                             // .
                })
                Return (RBUF) /* \_SB_.HID2._CRS.RBUF */
            }
        }

        Device (GPIO)
        {
            Name (_HID, "AMDI0030")  // _HID: Hardware ID
            Name (_CID, "AMDI0030")  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x17)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x0D, 0x01, 0x07, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x15, 0xD8,  // ........
                    /* 0010 */  0xFE, 0x00, 0x04, 0x00, 0x00, 0x79, 0x00         // .....y.
                })
                Return (RBUF) /* \_SB_.GPIO._CRS.RBUF */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    Return (0x0F)
                }
                Else
                {
                    Return (Zero)
                }
            }
        }

        Device (PPKG)
        {
            Name (_HID, "AMDI0052")  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (Zero)
            }
        }

        Device (PPKK)
        {
            Name (_HID, "AMDI0053")  // _HID: Hardware ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (((HPTI == One) && (HCOR == One)))
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
        }

        Device (FUR0)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((UT0O == One))
                {
                    Return ("AMDI0029")
                }

                Return ("AMDI0020")
            }

            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x03, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x90, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0x70, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ..p.....
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA0 /* \_SB_.IUA0 */
                Return (BUF0) /* \_SB_.FUR0._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (Zero)
                If ((TSOS >= 0x70))
                {
                    If ((UT0E == One))
                    {
                        If ((Local1 == 0x0F))
                        {
                            Local0 = 0x0F
                        }
                    }
                }

                If ((UT0I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT0D && UT0E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT0D && UT0E))
                {
                    DSAD (0x0B, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT0D && UT0E))
                {
                    DSAD (0x0B, 0x03)
                }
            }
        }

        Device (FUR1)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((UT1O == One))
                {
                    Return ("AMDI0029")
                }

                Return ("AMDI0020")
            }

            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x0E, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0xA0, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0x80, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA1 /* \_SB_.IUA1 */
                Return (BUF0) /* \_SB_.FUR1._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (One)
                If ((TSOS >= 0x70))
                {
                    If ((UT1E == One))
                    {
                        If ((Local1 == 0x0F))
                        {
                            Local0 = 0x0F
                        }
                    }
                }

                If ((UT1I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT1D && UT1E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT1D && UT1E))
                {
                    DSAD (0x0C, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT1D && UT1E))
                {
                    DSAD (0x0C, 0x03)
                }
            }
        }

        Device (FUR2)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((UT2O == One))
                {
                    Return ("AMDI0029")
                }

                Return ("AMDI0020")
            }

            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x05, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0xE0, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0xC0, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA2 /* \_SB_.IUA2 */
                Return (BUF0) /* \_SB_.FUR2._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (0x02)
                If ((TSOS >= 0x70))
                {
                    If ((UT2E == One))
                    {
                        If ((Local1 == 0x0F))
                        {
                            Local0 = 0x0F
                        }
                    }
                }

                If ((UT2I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT2D && UT2E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT2D && UT2E))
                {
                    DSAD (0x10, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT2D && UT2E))
                {
                    DSAD (0x10, 0x03)
                }
            }
        }

        Device (FUR3)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((UT3O == One))
                {
                    Return ("AMDI0029")
                }

                Return ("AMDI0020")
            }

            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x0F, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0xF0, 0xDC,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0xD0, 0xDC, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateWordField (BUF0, 0x05, IRQW)
                IRQW = IUA3 /* \_SB_.IUA3 */
                Return (BUF0) /* \_SB_.FUR3._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (0x03)
                If ((TSOS >= 0x70))
                {
                    If ((UT3E == One))
                    {
                        If ((Local1 == 0x0F))
                        {
                            Local0 = 0x0F
                        }
                    }
                }

                If ((UT3I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT3D && UT3E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT3D && UT3E))
                {
                    DSAD (0x1A, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT3D && UT3E))
                {
                    DSAD (0x1A, 0x03)
                }
            }
        }

        Device (FUR4)
        {
            Name (_HID, "AMDI0020")  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x23)
                {
                    /* 0000 */  0x89, 0x06, 0x00, 0x03, 0x01, 0x10, 0x00, 0x00,  // ........
                    /* 0008 */  0x00, 0x86, 0x09, 0x00, 0x01, 0x00, 0x10, 0xDD,  // ........
                    /* 0010 */  0xFE, 0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00,  // ........
                    /* 0018 */  0x01, 0x00, 0x00, 0xDD, 0xFE, 0x00, 0x10, 0x00,  // ........
                    /* 0020 */  0x00, 0x79, 0x00                                 // .y.
                })
                CreateByteField (BUF0, 0x05, IRQB)
                IRQB = IIF7 /* \_SB_.IIF7 */
                Return (BUF0) /* \_SB_.FUR4._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                If ((TSOS >= 0x70))
                {
                    If ((UT4E == One))
                    {
                        Local0 = 0x0F
                    }
                }

                If ((UT4I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((UT4D && UT4E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((UT4D && UT4E))
                {
                    DSAD (0x14, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((UT4D && UT4E))
                {
                    DSAD (0x14, 0x03)
                }
            }
        }

        Device (I2CA)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x00, 0x04, 0x01, 0x86, 0x09, 0x00, 0x01,  // #.......
                    /* 0008 */  0x00, 0x20, 0xDC, 0xFE, 0x00, 0x10, 0x00, 0x00,  // . ......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC0I & 0x0F))
                Return (BUF0) /* \_SB_.I2CA._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC0E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x05, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC0D && IC0E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC0D && IC0E))
                {
                    DSAD (0x05, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC0D && IC0E))
                {
                    DSAD (0x05, 0x03)
                }
            }
        }

        Device (I2CB)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x00, 0x08, 0x01, 0x86, 0x09, 0x00, 0x01,  // #.......
                    /* 0008 */  0x00, 0x30, 0xDC, 0xFE, 0x00, 0x10, 0x00, 0x00,  // .0......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC1I & 0x0F))
                Return (BUF0) /* \_SB_.I2CB._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC1E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x06, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC1D && IC1E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC1D && IC1E))
                {
                    DSAD (0x06, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC1D && IC1E))
                {
                    DSAD (0x06, 0x03)
                }
            }
        }

        Device (I2CC)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x10, 0x00, 0x01, 0x86, 0x09, 0x00, 0x01,  // #.......
                    /* 0008 */  0x00, 0x40, 0xDC, 0xFE, 0x00, 0x10, 0x00, 0x00,  // .@......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC2I & 0x0F))
                Return (BUF0) /* \_SB_.I2CC._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC2E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x07, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC2D && IC2E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC2D && IC2E))
                {
                    DSAD (0x07, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC2D && IC2E))
                {
                    DSAD (0x07, 0x03)
                }
            }
        }

        Device (I2CD)
        {
            Name (_HID, "AMDI0010")  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x40, 0x00, 0x01, 0x86, 0x09, 0x00, 0x01,  // #@......
                    /* 0008 */  0x00, 0x50, 0xDC, 0xFE, 0x00, 0x10, 0x00, 0x00,  // .P......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC3I & 0x0F))
                Return (BUF0) /* \_SB_.I2CD._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((IC3E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If ((Arg0 == ToUUID ("d93e4d1c-58bb-493c-a06a-605a717f9e2e") /* Unknown UUID */))
                {
                    Switch (ToInteger (Arg2))
                    {
                        Case (Zero)
                        {
                            Return (Buffer (One)
                            {
                                 0x03                                             // .
                            })
                        }
                        Case (One)
                        {
                            Return (Buffer (0x04)
                            {
                                 0xE5, 0x00, 0x6A, 0x00                           // ..j.
                            })
                        }

                    }
                }
                Else
                {
                    Return (Buffer (One)
                    {
                         0x00                                             // .
                    })
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x08, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((IC3D && IC3E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((IC3D && IC3E))
                {
                    DSAD (0x08, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((IC3D && IC3E))
                {
                    DSAD (0x08, 0x03)
                }
            }
        }

        Name (I3ID, "AMDI0015")
        Name (I2ID, "AMDI0016")
        Device (I3CA)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I30M == Zero))
                {
                    Return (I3ID) /* \_SB_.I3ID */
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, Zero)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x00, 0x04, 0x01, 0x86, 0x09, 0x00, 0x01,  // #.......
                    /* 0008 */  0x00, 0x20, 0xDD, 0xFE, 0x00, 0x10, 0x00, 0x00,  // . ......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC0I & 0x0F))
                Return (BUF0) /* \_SB_.I3CA._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((I30E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x15, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I30D && I30E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I30D && I30E))
                {
                    DSAD (0x15, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I30D && I30E))
                {
                    DSAD (0x15, 0x03)
                }
            }
        }

        Device (I3CB)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I31M == Zero))
                {
                    Return (I3ID) /* \_SB_.I3ID */
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, One)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x00, 0x08, 0x01, 0x86, 0x09, 0x00, 0x01,  // #.......
                    /* 0008 */  0x00, 0x30, 0xDD, 0xFE, 0x00, 0x10, 0x00, 0x00,  // .0......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC1I & 0x0F))
                Return (BUF0) /* \_SB_.I3CB._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((I31E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x0D, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I31D && I31E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I31D && I31E))
                {
                    DSAD (0x0D, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I31D && I31E))
                {
                    DSAD (0x0D, 0x03)
                }
            }
        }

        Device (I3CC)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I32M == Zero))
                {
                    Return (I3ID) /* \_SB_.I3ID */
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, 0x02)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x10, 0x00, 0x01, 0x86, 0x09, 0x00, 0x01,  // #.......
                    /* 0008 */  0x00, 0x40, 0xDD, 0xFE, 0x00, 0x10, 0x00, 0x00,  // .@......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC2I & 0x0F))
                Return (BUF0) /* \_SB_.I3CC._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((I32E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x0E, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I32D && I32E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I32D && I32E))
                {
                    DSAD (0x0E, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I32D && I32E))
                {
                    DSAD (0x0E, 0x03)
                }
            }
        }

        Device (I3CD)
        {
            Method (_HID, 0, Serialized)  // _HID: Hardware ID
            {
                If ((I33M == Zero))
                {
                    Return (I3ID) /* \_SB_.I3ID */
                }
                Else
                {
                    Return (I2ID) /* \_SB_.I2ID */
                }
            }

            Name (_UID, 0x03)  // _UID: Unique ID
            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x23, 0x40, 0x00, 0x01, 0x86, 0x09, 0x00, 0x01,  // #@......
                    /* 0008 */  0x00, 0x60, 0xDD, 0xFE, 0x00, 0x10, 0x00, 0x00,  // .`......
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                CreateWordField (BUF0, One, IRQW)
                IRQW = (One << (IC3I & 0x0F))
                Return (BUF0) /* \_SB_.I3CD._CRS.BUF0 */
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If ((TSOS >= 0x70))
                {
                    If ((I33E == One))
                    {
                        Return (0x0F)
                    }

                    Return (Zero)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (RSET, 0, NotSerialized)
            {
                SRAD (0x0F, 0xC8)
            }

            Method (_S0W, 0, NotSerialized)  // _S0W: S0 Device Wake State
            {
                If ((I33D && I33E))
                {
                    Return (0x04)
                }
                Else
                {
                    Return (Zero)
                }
            }

            Method (_PS0, 0, NotSerialized)  // _PS0: Power State 0
            {
                If ((I33D && I33E))
                {
                    DSAD (0x0F, Zero)
                }
            }

            Method (_PS3, 0, NotSerialized)  // _PS3: Power State 3
            {
                If ((I33D && I33E))
                {
                    DSAD (0x0F, 0x03)
                }
            }
        }
    }

    Scope (_SB.PCI0)
    {
        Device (UAR1)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_DDN, "COM1")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (Zero)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL0I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xE8, 0x02, 0xE8, 0x02, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x08, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (Zero)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (Zero) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR1._CRS.BUF0 */
            }
        }

        Device (UAR2)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x02)  // _UID: Unique ID
            Name (_DDN, "COM2")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (One)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL1I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xF8, 0x02, 0xF8, 0x02, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x10, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (One)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (One) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR2._CRS.BUF0 */
            }
        }

        Device (UAR3)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x03)  // _UID: Unique ID
            Name (_DDN, "COM3")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (0x02)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL2I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xE8, 0x03, 0xE8, 0x03, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x08, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (0x02)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (0x02) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR3._CRS.BUF0 */
            }
        }

        Device (UAR4)
        {
            Name (_HID, EisaId ("PNP0500") /* Standard PC COM Serial Port */)  // _HID: Hardware ID
            Name (_UID, 0x04)  // _UID: Unique ID
            Name (_DDN, "COM4")  // _DDN: DOS Device Name
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Local0 = Zero
                Local1 = FUIO (0x03)
                If ((Local1 != 0x0F))
                {
                    Local0 = 0x0F
                }

                If ((UL3I == One))
                {
                    Local0 = Zero
                }

                Return (Local0)
            }

            Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x0D)
                {
                    /* 0000 */  0x47, 0x01, 0xF8, 0x03, 0xF8, 0x03, 0x01, 0x08,  // G.......
                    /* 0008 */  0x22, 0x10, 0x00, 0x79, 0x00                     // "..y.
                })
                CreateByteField (BUF0, 0x02, IOLO)
                CreateByteField (BUF0, 0x03, IOHI)
                CreateByteField (BUF0, 0x04, IORL)
                CreateByteField (BUF0, 0x05, IORH)
                CreateWordField (BUF0, 0x09, IRQL)
                Local0 = FUIO (0x03)
                Switch (ToInteger (Local0))
                {
                    Case (Zero)
                    {
                        IOLO = 0xE8
                        IOHI = 0x02
                        IORL = 0xE8
                        IORH = 0x02
                    }
                    Case (One)
                    {
                        IOLO = 0xF8
                        IOHI = 0x02
                        IORL = 0xF8
                        IORH = 0x02
                    }
                    Case (0x02)
                    {
                        IOLO = 0xE8
                        IOHI = 0x03
                        IORL = 0xE8
                        IORH = 0x03
                    }
                    Case (0x03)
                    {
                        IOLO = 0xF8
                        IOHI = 0x03
                        IORL = 0xF8
                        IORH = 0x03
                    }

                }

                IRQL = (One << (FRUI (0x03) & 0x0F))
                Return (BUF0) /* \_SB_.PCI0.UAR4._CRS.BUF0 */
            }
        }
    }

    Scope (_SB.PCI0.SBRG)
    {
        Device (PS2K)
        {
            Name (_HID, EisaId ("PNP0303") /* IBM Enhanced Keyboard (101/102-key, PS/2 Mouse) */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Name (_CRS, Buffer (0x15)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x47, 0x01, 0x60, 0x00, 0x60, 0x00, 0x00, 0x01,  // G.`.`...
                /* 0008 */  0x47, 0x01, 0x64, 0x00, 0x64, 0x00, 0x00, 0x01,  // G.d.d...
                /* 0010 */  0x22, 0x02, 0x00, 0x79, 0x00                     // "..y.
            })
            Name (_PRS, Buffer (0x18)  // _PRS: Possible Resource Settings
            {
                /* 0000 */  0x31, 0x00, 0x47, 0x01, 0x60, 0x00, 0x60, 0x00,  // 1.G.`.`.
                /* 0008 */  0x00, 0x01, 0x47, 0x01, 0x64, 0x00, 0x64, 0x00,  // ..G.d.d.
                /* 0010 */  0x00, 0x01, 0x22, 0x02, 0x00, 0x38, 0x79, 0x00   // .."..8y.
            })
            Method (_PSW, 1, NotSerialized)  // _PSW: Power State Wake
            {
                KBFG = Arg0
            }
        }

        Scope (\)
        {
            Name (KBFG, One)
        }
    }

    Device (_SB.TPM)
    {
        Name (TMRQ, 0xFFFFFFFF)
        Name (TLVL, 0xFFFFFFFF)
        Name (HPMB, 0xFD500000)
        Name (HPML, 0x00100000)
        Name (ITRV, 0xFFFFFFFF)
        Name (ILVV, 0xFFFFFFFF)
        Method (_HID, 0, NotSerialized)  // _HID: Hardware ID
        {
            If (TCMF)
            {
                Return (0x01013469)
            }
            ElseIf ((TTDP == Zero))
            {
                Return (0x310CD041)
            }
            Else
            {
                Return ("MSFT0101")
            }
        }

        OperationRegion (TMMB, SystemMemory, 0xFED40000, 0x5000)
        Field (TMMB, ByteAcc, Lock, Preserve)
        {
            ACC0,   8, 
            Offset (0x08), 
            INTE,   32, 
            INTV,   8, 
            Offset (0x10), 
            INTS,   32, 
            INTF,   32, 
            TSTS,   32, 
            Offset (0x24), 
            FIFO,   32, 
            Offset (0x30), 
            IDTF,   32, 
            Offset (0x4C), 
            SCMD,   32
        }

        Method (_STR, 0, NotSerialized)  // _STR: Description String
        {
            If ((TTDP == Zero))
            {
                Return (Unicode ("TPM 1.2 Device"))
            }
            Else
            {
                Return (Unicode ("TPM 2.0 Device"))
            }
        }

        Name (_UID, One)  // _UID: Unique ID
        Name (CRST, Buffer (0x1A)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,  // ........
            /* 0008 */  0x00, 0x10, 0x00, 0x00, 0x86, 0x09, 0x00, 0x00,  // ........
            /* 0010 */  0x00, 0x00, 0xD7, 0xFE, 0x00, 0x10, 0x00, 0x00,  // ........
            /* 0018 */  0x79, 0x00                                       // y.
        })
        Name (CRSD, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD4, 0xFE,  // ........
            /* 0008 */  0x00, 0x50, 0x00, 0x00, 0x79, 0x00               // .P..y.
        })
        Name (CRID, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD4, 0xFE,  // ........
            /* 0008 */  0x00, 0x50, 0x00, 0x00, 0x79, 0x00               // .P..y.
        })
        Name (CREI, Buffer (0x31)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0xD4, 0xFE,  // ........
            /* 0008 */  0x00, 0x50, 0x00, 0x00, 0x8C, 0x20, 0x00, 0x01,  // .P... ..
            /* 0010 */  0x00, 0x01, 0x00, 0x12, 0x00, 0x03, 0x00, 0x00,  // ........
            /* 0018 */  0x00, 0x00, 0x17, 0x00, 0x00, 0x19, 0x00, 0x23,  // .......#
            /* 0020 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x5C, 0x5F, 0x53,  // .....\_S
            /* 0028 */  0x42, 0x2E, 0x47, 0x50, 0x49, 0x4F, 0x00, 0x79,  // B.GPIO.y
            /* 0030 */  0x00                                             // .
        })
        Name (CRSI, Buffer (0x0E)
        {
            /* 0000 */  0x86, 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,  // ........
            /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x79, 0x00               // ....y.
        })
        Method (_CRS, 0, Serialized)  // _CRS: Current Resource Settings
        {
            If ((AMDT == One))
            {
                CreateDWordField (CRST, 0x04, MTFB)
                CreateDWordField (CRST, 0x08, LTFB)
                MTFB = TPMB /* \TPMB */
                LTFB = TPBS /* \TPBS */
                CreateDWordField (CRST, 0x10, MTFC)
                CreateDWordField (CRST, 0x14, LTFC)
                MTFC = TPMC /* \TPMC */
                LTFC = TPCS /* \TPCS */
                Return (CRST) /* \_SB_.TPM_.CRST */
            }
            Else
            {
                If ((DTPT == One))
                {
                    CreateDWordField (CRSD, 0x04, MTFE)
                    CreateDWordField (CRSD, 0x08, LTFE)
                    MTFE = 0xFED40000
                    LTFE = 0x5000
                    Return (CRSD) /* \_SB_.TPM_.CRSD */
                }
                ElseIf ((TTPF == One))
                {
                    If (((TMRQ == Zero) || (TMRQ == 0xFFFFFFFF)))
                    {
                        CreateDWordField (CRID, 0x04, MTFD)
                        CreateDWordField (CRID, 0x08, LTFD)
                        MTFD = 0xFED40000
                        LTFD = 0x5000
                        Return (CRID) /* \_SB_.TPM_.CRID */
                    }
                    Else
                    {
                        CreateWordField (CREI, 0x23, LIRQ)
                        CreateBitField (CREI, 0x99, LLVL)
                        LIRQ = TMRQ /* \_SB_.TPM_.TMRQ */
                        LLVL = TLVL /* \_SB_.TPM_.TLVL */
                        Return (CREI) /* \_SB_.TPM_.CREI */
                    }
                }
                ElseIf ((TTPF == Zero))
                {
                    If ((AMDT == 0x02))
                    {
                        If (((HPMB != Zero) && (HPMB != 0xFFFFFFFF)))
                        {
                            CreateDWordField (CRSI, 0x04, HSPB)
                            CreateDWordField (CRSI, 0x08, HSPL)
                            HSPB = HPMB /* \_SB_.TPM_.HPMB */
                            HSPL = HPML /* \_SB_.TPM_.HPML */
                        }

                        Return (CRSI) /* \_SB_.TPM_.CRSI */
                    }

                    CreateDWordField (CRST, 0x10, MTFF)
                    MTFF = FTPM /* \FTPM */
                    Return (CRST) /* \_SB_.TPM_.CRST */
                }

                MTFE = Zero
                LTFE = Zero
                Return (CRID) /* \_SB_.TPM_.CRID */
            }

            Return (CRID) /* \_SB_.TPM_.CRID */
        }

        Method (_SRS, 1, Serialized)  // _SRS: Set Resource Settings
        {
            If (((TMRQ != Zero) && (TMRQ != 0xFFFFFFFF)))
            {
                If ((AMDT == 0x02)){}
                Else
                {
                    CreateWordField (Arg0, 0x23, IRQ0)
                    CreateWordField (CREI, 0x23, LIRQ)
                    LIRQ = IRQ0 /* \_SB_.TPM_._SRS.IRQ0 */
                    TMRQ = IRQ0 /* \_SB_.TPM_._SRS.IRQ0 */
                    CreateBitField (Arg0, 0x98, ITRG)
                    CreateBitField (CREI, 0x98, LTRG)
                    LTRG = ITRG /* \_SB_.TPM_._SRS.ITRG */
                    ITRV = ITRG /* \_SB_.TPM_._SRS.ITRG */
                    CreateBitField (Arg0, 0x99, ILVL)
                    CreateBitField (CREI, 0x99, LLVL)
                    LLVL = ILVL /* \_SB_.TPM_._SRS.ILVL */
                    ILVV = ILVL /* \_SB_.TPM_._SRS.ILVL */
                }

                If ((((IDTF & 0x0F) == Zero) || ((IDTF & 0x0F
                    ) == 0x0F)))
                {
                    If ((IRQ0 < 0x10))
                    {
                        INTV = (IRQ0 & 0x0F)
                    }

                    If ((ITRV == One))
                    {
                        INTE |= 0x10
                    }
                    Else
                    {
                        INTE &= 0xFFFFFFEF
                    }

                    If ((ILVV == Zero))
                    {
                        INTE |= 0x08
                    }
                    Else
                    {
                        INTE &= 0xFFFFFFF7
                    }
                }
            }
        }

        OperationRegion (CRBD, SystemMemory, TPMM, 0x48)
        Field (CRBD, AnyAcc, NoLock, Preserve)
        {
            Offset (0x04), 
            HERR,   32, 
            Offset (0x40), 
            HCMD,   32, 
            Offset (0x44), 
            HSTS,   32
        }

        Method (_STA, 0, NotSerialized)  // _STA: Status
        {
            If ((TTDP == Zero))
            {
                If (TPMF)
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
            ElseIf ((TTDP == One))
            {
                If (TPMF)
                {
                    Return (0x0F)
                }

                Return (Zero)
            }

            Return (Zero)
        }

        Method (STRT, 3, Serialized)
        {
            OperationRegion (TPMR, SystemMemory, FTPM, 0x1000)
            Field (TPMR, AnyAcc, NoLock, Preserve)
            {
                Offset (0x04), 
                FERR,   32, 
                Offset (0x0C), 
                BEGN,   32
            }

            Name (TIMR, Zero)
            If ((ToInteger (Arg0) != Zero)){}
            Switch (ToInteger (Arg1))
            {
                Case (Zero)
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }
                Case (One)
                {
                    TIMR = Zero
                    If ((AMDT == One))
                    {
                        While (((BEGN == One) && (TIMR < 0x0200)))
                        {
                            If ((BEGN == One))
                            {
                                Sleep (One)
                                TIMR++
                            }
                        }
                    }
                    ElseIf ((((HSTS & 0x02) | (HSTS & One)
                        ) == 0x03))
                    {
                        HCMD = One
                    }
                    Else
                    {
                        FERR = One
                        BEGN = Zero
                    }

                    Return (Zero)
                }

            }

            Return (One)
        }

        Method (CRYF, 3, Serialized)
        {
            If ((ToInteger (Arg0) != One)){}
            Switch (ToInteger (Arg1))
            {
                Case (Zero)
                {
                    Return (Buffer (One)
                    {
                         0x03                                             // .
                    })
                }
                Case (One)
                {
                    Name (TPMV, Package (0x02)
                    {
                        One, 
                        Package (0x02)
                        {
                            One, 
                            0x20
                        }
                    })
                    If ((_STA () == Zero))
                    {
                        Return (Package (0x01)
                        {
                            Zero
                        })
                    }

                    Return (TPMV) /* \_SB_.TPM_.CRYF.TPMV */
                }

            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }
    }

    Scope (_SB.TPM)
    {
        OperationRegion (TSMI, SystemIO, SMIA, 0x02)
        Field (TSMI, WordAcc, NoLock, Preserve)
        {
            SMI,    16
        }

        OperationRegion (ATNV, SystemMemory, PPIM, PPIL)
        Field (ATNV, AnyAcc, NoLock, Preserve)
        {
            RQST,   32, 
            RCNT,   32, 
            ERRO,   32, 
            FLAG,   32, 
            MISC,   32, 
            OPTN,   32, 
            SRSP,   32
        }

        Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
        {
            If ((Arg0 == ToUUID ("3dddfaa6-361b-4eb4-a424-8d10089d1653") /* Physical Presence Interface */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (0x02)
                        {
                             0xFF, 0x01                                       // ..
                        })
                    }
                    Case (One)
                    {
                        If ((PPIV == Zero))
                        {
                            Return ("1.2")
                        }
                        Else
                        {
                            Return ("1.3")
                        }
                    }
                    Case (0x02)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        SRSP = Zero
                        FLAG = 0x02
                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Case (0x03)
                    {
                        Name (PPI1, Package (0x02)
                        {
                            Zero, 
                            Zero
                        })
                        PPI1 [One] = RQST /* \_SB_.TPM_.RQST */
                        Return (PPI1) /* \_SB_.TPM_._DSM.PPI1 */
                    }
                    Case (0x04)
                    {
                        Return (TRST) /* \TRST */
                    }
                    Case (0x05)
                    {
                        Name (PPI2, Package (0x03)
                        {
                            Zero, 
                            Zero, 
                            Zero
                        })
                        SRSP = Zero
                        FLAG = 0x05
                        SMI = OFST /* \OFST */
                        PPI2 [One] = RCNT /* \_SB_.TPM_.RCNT */
                        PPI2 [0x02] = ERRO /* \_SB_.TPM_.ERRO */
                        Return (PPI2) /* \_SB_.TPM_._DSM.PPI2 */
                    }
                    Case (0x06)
                    {
                        Return (0x03)
                    }
                    Case (0x07)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        FLAG = 0x07
                        OPTN = Zero
                        If ((RQST == 0x17))
                        {
                            ToInteger (DerefOf (Arg3 [One]), OPTN) /* \_SB_.TPM_.OPTN */
                        }

                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Case (0x08)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        FLAG = 0x08
                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Default
                    {
                    }

                }
            }
            ElseIf ((Arg0 == ToUUID ("376054ed-cc13-4675-901c-4756d7f2d45d") /* TPM Memory Clear */))
            {
                Switch (ToInteger (Arg2))
                {
                    Case (Zero)
                    {
                        Return (Buffer (One)
                        {
                             0x03                                             // .
                        })
                    }
                    Case (One)
                    {
                        RQST = DerefOf (Arg3 [Zero])
                        FLAG = 0x09
                        TMF1 = OFST /* \OFST */
                        SRSP = Zero
                        SMI = TMF1 /* \TMF1 */
                        Return (SRSP) /* \_SB_.TPM_.SRSP */
                    }
                    Default
                    {
                    }

                }
            }

            If ((Arg0 == ToUUID ("cf8e16a5-c1e8-4e25-b712-4f54a96702c8") /* TPM Hardware Information */))
            {
                Return (CRYF (Arg1, Arg2, Arg3))
            }

            If ((Arg0 == ToUUID ("6bbf6cab-5463-4714-b7cd-f0203c0368d4") /* TPM Start Method */))
            {
                Return (STRT (Arg1, Arg2, Arg3))
            }

            Return (Buffer (One)
            {
                 0x00                                             // .
            })
        }

        Method (TPTS, 1, Serialized)
        {
            Switch (ToInteger (Arg0))
            {
                Case (0x04)
                {
                    RQST = Zero
                    FLAG = 0x09
                    SRSP = Zero
                    SMI = OFST /* \OFST */
                }
                Case (0x05)
                {
                    RQST = Zero
                    FLAG = 0x09
                    SRSP = Zero
                    SMI = OFST /* \OFST */
                }

            }

            Sleep (0x012C)
        }
    }

    Scope (_SB)
    {
        Device (AMW0)
        {
            Name (_HID, "PNP0C14" /* Windows Management Instrumentation Device */)  // _HID: Hardware ID
            Name (_UID, Zero)  // _UID: Unique ID
            Name (_WDG, Buffer (0x28)
            {
                /* 0000 */  0x5C, 0x0F, 0xBC, 0xAB, 0xA1, 0x8E, 0xD1, 0x11,  // \.......
                /* 0008 */  0xA0, 0x00, 0xC9, 0x06, 0x29, 0x10, 0x00, 0x00,  // ....)...
                /* 0010 */  0xD2, 0x00, 0x01, 0x08, 0x21, 0x12, 0x90, 0x05,  // ....!...
                /* 0018 */  0x66, 0xD5, 0xD1, 0x11, 0xB2, 0xF0, 0x00, 0xA0,  // f.......
                /* 0020 */  0xC9, 0x06, 0x29, 0x10, 0x43, 0x43, 0x01, 0x00   // ..).CC..
            })
            Method (_WED, 1, NotSerialized)  // _Wxx: Wake Event, xx=0x00-0xFF
            {
                If ((Arg0 == 0xD2))
                {
                    Return (Zero)
                }
            }

            Name (WQCC, Buffer (0x0277)
            {
                /* 0000 */  0x46, 0x4F, 0x4D, 0x42, 0x01, 0x00, 0x00, 0x00,  // FOMB....
                /* 0008 */  0x67, 0x02, 0x00, 0x00, 0x04, 0x06, 0x00, 0x00,  // g.......
                /* 0010 */  0x44, 0x53, 0x00, 0x01, 0x1A, 0x7D, 0xDA, 0x54,  // DS...}.T
                /* 0018 */  0x18, 0xD6, 0x82, 0x00, 0x01, 0x06, 0x18, 0x42,  // .......B
                /* 0020 */  0x10, 0x05, 0x10, 0x22, 0x21, 0x04, 0x12, 0x01,  // ..."!...
                /* 0028 */  0xA1, 0xC8, 0x2C, 0x0C, 0x86, 0x10, 0x38, 0x2E,  // ..,...8.
                /* 0030 */  0x84, 0x1C, 0x40, 0x48, 0x1C, 0x14, 0x4A, 0x08,  // ..@H..J.
                /* 0038 */  0x84, 0xFA, 0x13, 0xC8, 0xAF, 0x00, 0x84, 0x0E,  // ........
                /* 0040 */  0x05, 0xC8, 0x14, 0x60, 0x50, 0x80, 0x53, 0x04,  // ...`P.S.
                /* 0048 */  0x11, 0xF4, 0x2A, 0xC0, 0xA6, 0x00, 0x93, 0x02,  // ..*.....
                /* 0050 */  0x2C, 0x0A, 0xD0, 0x2E, 0xC0, 0xB2, 0x00, 0xDD,  // ,.......
                /* 0058 */  0x02, 0xA4, 0xC3, 0x12, 0x91, 0xE0, 0x28, 0x31,  // ......(1
                /* 0060 */  0xE0, 0x28, 0x9D, 0xD8, 0xC2, 0x0D, 0x1B, 0xBC,  // .(......
                /* 0068 */  0x50, 0x14, 0xCD, 0x20, 0x4A, 0x82, 0xCA, 0x05,  // P.. J...
                /* 0070 */  0xF8, 0x46, 0x10, 0x78, 0xB9, 0x02, 0x24, 0x4F,  // .F.x..$O
                /* 0078 */  0x40, 0x9A, 0x05, 0x18, 0x16, 0x60, 0x5D, 0x80,  // @....`].
                /* 0080 */  0xEC, 0x21, 0x50, 0xA9, 0x43, 0x40, 0xC9, 0x19,  // .!P.C@..
                /* 0088 */  0x02, 0x6A, 0x00, 0xAD, 0x4E, 0x40, 0xF8, 0x95,  // .j..N@..
                /* 0090 */  0x4E, 0x09, 0x49, 0x10, 0xCE, 0x58, 0xC5, 0xE3,  // N.I..X..
                /* 0098 */  0x6B, 0x16, 0x4D, 0xCF, 0x49, 0xCE, 0x31, 0xE4,  // k.M.I.1.
                /* 00A0 */  0x78, 0x5C, 0xE8, 0x41, 0xF0, 0x88, 0x12, 0x40,  // x\.A...@
                /* 00A8 */  0x58, 0x90, 0x21, 0x2B, 0x14, 0x0C, 0x4A, 0xC3,  // X.!+..J.
                /* 00B0 */  0x58, 0xA8, 0x8B, 0x51, 0xA3, 0x46, 0xCA, 0x06,  // X..Q.F..
                /* 00B8 */  0x64, 0x88, 0x92, 0xE0, 0x50, 0xA3, 0xB6, 0x44,  // d...P..D
                /* 00C0 */  0x01, 0xE6, 0xC7, 0xA1, 0xD9, 0xB5, 0x3D, 0x16,  // ......=.
                /* 00C8 */  0x02, 0xC9, 0xA4, 0x0D, 0x05, 0x25, 0x05, 0x42,  // .....%.B
                /* 00D0 */  0x63, 0x3B, 0x53, 0xCF, 0x28, 0xE2, 0x91, 0x1A,  // c;S.(...
                /* 00D8 */  0x26, 0x81, 0x47, 0xC1, 0xD0, 0x38, 0xC1, 0x79,  // &.G..8.y
                /* 00E0 */  0x79, 0xF4, 0xB8, 0x61, 0x44, 0x3D, 0xC0, 0x93,  // y..aD=..
                /* 00E8 */  0x38, 0x45, 0x0B, 0xC7, 0x13, 0x46, 0xD0, 0x43,  // 8E...F.C
                /* 00F0 */  0x49, 0x70, 0x8E, 0x18, 0x41, 0x02, 0x3C, 0xA3,  // Ip..A.<.
                /* 00F8 */  0x90, 0x49, 0x78, 0x40, 0x81, 0x82, 0x9C, 0x47,  // .Ix@...G
                /* 0100 */  0xA8, 0xDE, 0x05, 0x88, 0xC6, 0x22, 0x28, 0x27,  // ....."('
                /* 0108 */  0x70, 0x1E, 0x31, 0x82, 0x9F, 0xC1, 0xFF, 0x3F,  // p.1....?
                /* 0110 */  0xC6, 0x09, 0x3C, 0x05, 0x3C, 0x06, 0x04, 0x8E,  // ..<.<...
                /* 0118 */  0x6C, 0x4C, 0xCF, 0xDB, 0x43, 0xC3, 0x8E, 0xD1,  // lL..C...
                /* 0120 */  0x67, 0x80, 0x23, 0x39, 0x99, 0x63, 0x08, 0x1B,  // g.#9.c..
                /* 0128 */  0x33, 0x81, 0x27, 0xF6, 0x18, 0xF0, 0x58, 0x50,  // 3.'...XP
                /* 0130 */  0xD8, 0x25, 0x40, 0xA8, 0x31, 0x9A, 0x83, 0x22,  // .%@.1.."
                /* 0138 */  0x70, 0xA1, 0x31, 0x32, 0x20, 0x34, 0x89, 0xC3,  // p.12 4..
                /* 0140 */  0x38, 0x4C, 0x13, 0xD8, 0xFD, 0x99, 0x40, 0x0A,  // 8L....@.
                /* 0148 */  0x11, 0x74, 0x2B, 0x88, 0xFB, 0x8A, 0xD0, 0xDA,  // .t+.....
                /* 0150 */  0x18, 0x64, 0xEB, 0x04, 0xA1, 0x31, 0x9C, 0x44,  // .d...1.D
                /* 0158 */  0x63, 0x28, 0x82, 0x88, 0x10, 0x34, 0x8A, 0x31,  // c(...4.1
                /* 0160 */  0x03, 0x46, 0x30, 0x4A, 0xC4, 0xB3, 0x08, 0x52,  // .F0J...R
                /* 0168 */  0x9B, 0x00, 0x65, 0x20, 0x42, 0x8B, 0xC5, 0x10,  // ..e B...
                /* 0170 */  0x6C, 0x7F, 0xC8, 0xEC, 0x45, 0xA1, 0x43, 0x81,  // l...E.C.
                /* 0178 */  0x23, 0x8D, 0x06, 0x75, 0x62, 0xF0, 0xC1, 0xC0,  // #..ub...
                /* 0180 */  0xE3, 0x7F, 0x50, 0xF0, 0x6C, 0x8F, 0x23, 0xC8,  // ..P.l.#.
                /* 0188 */  0x19, 0x1C, 0xC9, 0x73, 0xC4, 0x13, 0x81, 0x87,  // ...s....
                /* 0190 */  0xC7, 0xCE, 0x00, 0x3E, 0x60, 0xF8, 0x88, 0x80,  // ...>`...
                /* 0198 */  0x77, 0x0D, 0xA8, 0xBB, 0xC1, 0x93, 0x01, 0x1B,  // w.......
                /* 01A0 */  0x71, 0x38, 0xCC, 0x10, 0x7D, 0x02, 0x38, 0x34,  // q8..}.84
                /* 01A8 */  0x0F, 0x91, 0x01, 0x7A, 0x44, 0xC7, 0x8D, 0x1D,  // ...zD...
                /* 01B0 */  0xE5, 0xC9, 0x1C, 0xF4, 0x4B, 0x45, 0xB3, 0xD7,  // ....KE..
                /* 01B8 */  0x09, 0x42, 0x70, 0x3C, 0xBE, 0x49, 0xB0, 0x09,  // .Bp<.I..
                /* 01C0 */  0x27, 0xB0, 0xFC, 0x41, 0xA0, 0x46, 0x66, 0x68,  // '..A.Ffh
                /* 01C8 */  0x0F, 0xF5, 0xB4, 0x5E, 0x0F, 0x7C, 0x39, 0x30,  // ...^.|90
                /* 01D0 */  0x81, 0xC5, 0x9E, 0x47, 0xE8, 0x78, 0xC0, 0xAF,  // ...G.x..
                /* 01D8 */  0xF8, 0xF4, 0x41, 0x6E, 0x06, 0x9E, 0xAF, 0x09,  // ..An....
                /* 01E0 */  0xCA, 0x3A, 0x5E, 0xC8, 0xC9, 0x78, 0x50, 0xA3,  // .:^..xP.
                /* 01E8 */  0xB0, 0x46, 0x40, 0xE1, 0x1D, 0x17, 0xFB, 0xFF,  // .F@.....
                /* 01F0 */  0xCB, 0x00, 0xD4, 0x7F, 0x45, 0x02, 0x44, 0x0D,  // ....E.D.
                /* 01F8 */  0x9B, 0x1E, 0x2B, 0xF8, 0x89, 0xE2, 0xED, 0xC2,  // ..+.....
                /* 0200 */  0x47, 0x87, 0xF7, 0x07, 0x43, 0x1C, 0xC9, 0x09,  // G...C...
                /* 0208 */  0xF9, 0xD7, 0xE2, 0x81, 0xC1, 0x07, 0xC4, 0x9F,  // ........
                /* 0210 */  0x26, 0x4E, 0xD9, 0x17, 0x0A, 0x03, 0xB2, 0x93,  // &N......
                /* 0218 */  0x03, 0xEE, 0x8C, 0x01, 0x77, 0x64, 0xFC, 0x50,  // ....wd.P
                /* 0220 */  0xC1, 0x06, 0xF2, 0x02, 0xE2, 0x31, 0xF9, 0x16,  // .....1..
                /* 0228 */  0xC0, 0x2E, 0x18, 0xE0, 0x18, 0x3B, 0x18, 0xEE,  // .....;..
                /* 0230 */  0x15, 0xBE, 0x7B, 0xD8, 0xD9, 0x49, 0x42, 0x04,  // ..{..IB.
                /* 0238 */  0x3E, 0xE5, 0x80, 0x63, 0x38, 0xBE, 0xC2, 0x58,  // >..c8..X
                /* 0240 */  0x2B, 0x84, 0x8E, 0x11, 0x6F, 0x34, 0x3E, 0xE5,  // +...o4>.
                /* 0248 */  0x00, 0x93, 0x71, 0x3C, 0xE5, 0x80, 0xED, 0x20,  // ..q<... 
                /* 0250 */  0x04, 0x67, 0x00, 0x5C, 0xA1, 0x4D, 0x9F, 0x1A,  // .g.\.M..
                /* 0258 */  0x8D, 0x5A, 0x35, 0x28, 0x53, 0xA3, 0x4C, 0x83,  // .Z5(S.L.
                /* 0260 */  0x5A, 0x7D, 0x2A, 0x35, 0x66, 0xEC, 0x9C, 0x60,  // Z}*5f..`
                /* 0268 */  0x69, 0x14, 0x02, 0x71, 0x30, 0x10, 0x1A, 0xF7,  // i..q0...
                /* 0270 */  0x9C, 0xA3, 0xFF, 0x3F, 0x88, 0xFF, 0xFF         // ...?...
            })
        }

        Device (ACAD)
        {
            Name (_HID, "ACPI0003" /* Power Source Device */)  // _HID: Hardware ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB, 
            })
            Name (XX00, Buffer (0x03){})
            Name (ACDC, 0xFF)
            Method (_PSR, 0, NotSerialized)  // _PSR: Power Source
            {
                M460 ("PLA-ASL-\\_SB.ACAD._PSR Start\n", Zero, Zero, Zero, Zero, Zero, Zero)
                Local0 = One
                If (^^PCI0.SBRG.ECOK ())
                {
                    If (!Acquire (^^PCI0.SBRG.EC0.Z009, 0x012C))
                    {
                        Local0 = ^^PCI0.SBRG.EC0.CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                        Local0 &= One
                        CreateWordField (XX00, Zero, SSZE)
                        CreateByteField (XX00, 0x02, ACST)
                        SSZE = 0x03
                        If ((Local0 != ACDC))
                        {
                            If (Local0)
                            {
                                P80H = 0xECAC
                                If (CondRefOf (AFN4))
                                {
                                    M460 ("PLA-ASL-\\_SB.ACAD._PSR call AFN4(0x1)\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                    AFN4 (One)
                                }

                                ACST = Zero
                            }
                            Else
                            {
                                P80H = 0xECDC
                                If (CondRefOf (AFN4))
                                {
                                    M460 ("PLA-ASL-\\_SB.ACAD._PSR call AFN4(0x2)\n", Zero, Zero, Zero, Zero, Zero, Zero)
                                    AFN4 (0x02)
                                }

                                ACST = One
                            }

                            M460 ("PLA-ASL-\\_SB.ACAD._PSR call \\_SB.ALIB(1, 0x%X)\n", XX00, Zero, Zero, Zero, Zero, Zero)
                            ALIB (One, XX00)
                            ACDC = Local0
                        }

                        Release (^^PCI0.SBRG.EC0.Z009)
                    }
                }

                Return (Local0)
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }
        }

        Device (BATT)
        {
            Name (_HID, EisaId ("PNP0C0A") /* Control Method Battery */)  // _HID: Hardware ID
            Name (_UID, One)  // _UID: Unique ID
            Name (_PCL, Package (0x01)  // _PCL: Power Consumer List
            {
                _SB, 
            })
            Name (PBIX, Package (0x15)
            {
                One, 
                One, 
                0xFFFFFFFF, 
                0xFFFFFFFF, 
                One, 
                0xFFFFFFFF, 
                0x0A, 
                0x04, 
                Zero, 
                0x00017318, 
                0xFFFFFFFF, 
                0xFFFFFFFF, 
                0x88B8, 
                0x61A8, 
                One, 
                One, 
                "SR Real Battery", 
                "123456789", 
                "LION", 
                "Standard", 
                Zero
            })
            Method (_BTP, 1, NotSerialized)  // _BTP: Battery Trip Point
            {
                If (^^PCI0.SBRG.ECOK ())
                {
                    If (!Acquire (^^PCI0.SBRG.EC0.Z009, 0x012C))
                    {
                        If ((Arg0 == Zero))
                        {
                            Local0 = Zero
                            Local1 = Zero
                        }
                        Else
                        {
                            Local0 = (Arg0 & 0xFF)
                            Local1 = (Arg0 >> 0x08)
                            Local1 &= 0xFF
                        }

                        ^^PCI0.SBRG.EC0.BTPL = Local0
                        ^^PCI0.SBRG.EC0.BTPH = Local1
                        Release (^^PCI0.SBRG.EC0.Z009)
                    }
                }
            }

            Name (PBST, Package (0x04)
            {
                Zero, 
                0xFFFFFFFF, 
                0xFFFFFFFF, 
                0xFFFFFFFF
            })
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                If (^^PCI0.SBRG.ECOK ())
                {
                    If (!Acquire (^^PCI0.SBRG.EC0.Z009, 0x012C))
                    {
                        Local0 = ^^PCI0.SBRG.EC0.CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                        Release (^^PCI0.SBRG.EC0.Z009)
                        If ((Local0 & 0x02))
                        {
                            Return (0x1F)
                        }
                        Else
                        {
                            Return (0x0B)
                        }
                    }
                }

                Return (0x0B)
            }

            Method (_BIX, 0, NotSerialized)  // _BIX: Battery Information Extended
            {
                If (^^PCI0.SBRG.ECOK ())
                {
                    If (!Acquire (^^PCI0.SBRG.EC0.Z009, 0x012C))
                    {
                        Local0 = ^^PCI0.SBRG.EC0.CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                        If (!(Local0 & 0x02))
                        {
                            PBIX [0x02] = 0xFFFFFFFF
                            PBIX [0x03] = 0xFFFFFFFF
                            PBIX [0x05] = 0xFFFFFFFF
                            PBIX [0x06] = 0x0A
                            PBIX [0x07] = 0x04
                            PBIX [0x08] = Zero
                            Release (^^PCI0.SBRG.EC0.Z009)
                            Return (PBIX) /* \_SB_.BATT.PBIX */
                        }

                        Local1 = ^^PCI0.SBRG.EC0.DEVH /* \_SB_.PCI0.SBRG.EC0_.DEVH */
                        Local1 <<= 0x08
                        Local1 &= 0xFF00
                        Local0 = ^^PCI0.SBRG.EC0.DEVL /* \_SB_.PCI0.SBRG.EC0_.DEVL */
                        Local0 &= 0xFF
                        Local0 |= Local1
                        PBIX [0x05] = Local0
                        Local1 = ^^PCI0.SBRG.EC0.DECH /* \_SB_.PCI0.SBRG.EC0_.DECH */
                        Local1 <<= 0x08
                        Local1 &= 0xFF00
                        Local0 = ^^PCI0.SBRG.EC0.DECL /* \_SB_.PCI0.SBRG.EC0_.DECL */
                        Local0 &= 0xFF
                        Local0 |= Local1
                        PBIX [0x02] = Local0
                        Divide (Local0, 0x0A, Local2, Local3)
                        PBIX [0x06] = Local3
                        Divide (Local0, 0x64, Local0, Local1)
                        PBIX [0x07] = Local1
                        Local1 = ^^PCI0.SBRG.EC0.LFCH /* \_SB_.PCI0.SBRG.EC0_.LFCH */
                        Local1 <<= 0x08
                        Local1 &= 0xFF00
                        Local0 = ^^PCI0.SBRG.EC0.LFCL /* \_SB_.PCI0.SBRG.EC0_.LFCL */
                        Local0 &= 0xFF
                        Local0 |= Local1
                        PBIX [0x03] = Local0
                        Local1 = ^^PCI0.SBRG.EC0.BCCH /* \_SB_.PCI0.SBRG.EC0_.BCCH */
                        Local1 <<= 0x08
                        Local1 &= 0xFF00
                        Local0 = ^^PCI0.SBRG.EC0.BCCL /* \_SB_.PCI0.SBRG.EC0_.BCCL */
                        Local0 &= 0xFF
                        Local0 |= Local1
                        PBIX [0x08] = Local0
                        Release (^^PCI0.SBRG.EC0.Z009)
                    }
                }

                Return (PBIX) /* \_SB_.BATT.PBIX */
            }

            Method (_BST, 0, NotSerialized)  // _BST: Battery Status
            {
                If (^^PCI0.SBRG.ECOK ())
                {
                    If (!Acquire (^^PCI0.SBRG.EC0.Z009, 0x012C))
                    {
                        Local0 = ^^PCI0.SBRG.EC0.CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                        If (!(Local0 & 0x02))
                        {
                            PBST [Zero] = Zero
                            PBST [One] = 0xFFFFFFFF
                            PBST [0x02] = 0xFFFFFFFF
                            PBST [0x03] = 0xFFFFFFFF
                            Release (^^PCI0.SBRG.EC0.Z009)
                            Return (PBST) /* \_SB_.BATT.PBST */
                        }

                        If ((Local0 & 0x02))
                        {
                            If ((Local0 & One))
                            {
                                Local4 = 0x02
                            }
                            Else
                            {
                                Local4 = Zero
                            }
                        }
                        Else
                        {
                            Local4 = Zero
                        }

                        If (!(Local0 & One))
                        {
                            If ((Local0 & 0x20))
                            {
                                Local4 = 0x05
                            }
                            Else
                            {
                                Local4 = One
                            }
                        }

                        PBST [Zero] = Local4
                        Local3 = ^^PCI0.SBRG.EC0.BTVH /* \_SB_.PCI0.SBRG.EC0_.BTVH */
                        Local2 = ^^PCI0.SBRG.EC0.BTVL /* \_SB_.PCI0.SBRG.EC0_.BTVL */
                        Local2 &= 0xFF
                        Local3 <<= 0x08
                        Local3 &= 0xFF00
                        Local7 = (Local2 | Local3)
                        PBST [0x03] = Local7
                        Local3 = ^^PCI0.SBRG.EC0.BTCH /* \_SB_.PCI0.SBRG.EC0_.BTCH */
                        Local2 = ^^PCI0.SBRG.EC0.BTCL /* \_SB_.PCI0.SBRG.EC0_.BTCL */
                        Local2 &= 0xFF
                        Local3 <<= 0x08
                        Local3 &= 0xFF00
                        Local5 = (Local2 | Local3)
                        PBST [One] = Local5
                        Local3 = ^^PCI0.SBRG.EC0.CAPH /* \_SB_.PCI0.SBRG.EC0_.CAPH */
                        Local2 = ^^PCI0.SBRG.EC0.CAPL /* \_SB_.PCI0.SBRG.EC0_.CAPL */
                        Local2 &= 0xFF
                        Local3 <<= 0x08
                        Local3 &= 0xFF00
                        Local6 = (Local2 | Local3)
                        PBST [0x02] = Local6
                        Release (^^PCI0.SBRG.EC0.Z009)
                    }
                }

                Return (PBST) /* \_SB_.BATT.PBST */
            }

            Name (BCTR, One)
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If (((Arg0 == ToUUID ("4c2067e3-887d-475c-9720-4af1d3ed602e") /* Battery Thermal Limit */) && (ToInteger (Arg1) == Zero)))
                {
                    If ((ToInteger (Arg2) == Zero))
                    {
                        Return (Buffer (One)
                        {
                             0x0D                                             // .
                        })
                    }
                    ElseIf ((ToInteger (Arg2) == One))
                    {
                        BCTR = Arg3
                        Local0 = (BCTR & 0xFF)
                        ^^PCI0.SBRG.EC0.BCTR = Local0
                    }
                    ElseIf ((ToInteger (Arg2) == 0x02))
                    {
                        Return (Package (0x01)
                        {
                            Zero
                        })
                    }
                    ElseIf ((ToInteger (Arg2) == 0x03))
                    {
                        Return (Package (0x01)
                        {
                            Zero
                        })
                    }
                }

                Return (Buffer (One)
                {
                     0x00                                             // .
                })
            }
        }

        Device (LID)
        {
            Name (_HID, EisaId ("PNP0C0D") /* Lid Device */)  // _HID: Hardware ID
            Method (_LID, 0, NotSerialized)  // _LID: Lid Status
            {
                If (^^PCI0.SBRG.ECOK ())
                {
                    Local0 = 0xFF
                    If (!Acquire (^^PCI0.SBRG.EC0.Z009, 0x012C))
                    {
                        Local0 = ^^PCI0.SBRG.EC0.DEVS /* \_SB_.PCI0.SBRG.EC0_.DEVS */
                        Release (^^PCI0.SBRG.EC0.Z009)
                    }

                    If ((Local0 & 0x02))
                    {
                        Return (One)
                    }
                    Else
                    {
                        Return (Zero)
                    }
                }

                Return (One)
            }
        }
    }

    Scope (_SB.PCI0.SBRG)
    {
        Method (ECOK, 0, NotSerialized)
        {
            If ((^EC0.OKEC == One))
            {
                Return (One)
            }
            Else
            {
                Return (Zero)
            }
        }

        Device (EC0)
        {
            Name (_HID, EisaId ("PNP0C09") /* Embedded Controller Device */)  // _HID: Hardware ID
            Name (_GPE, 0x17)  // _GPE: General Purpose Events
            Name (DPTI, Buffer (0x07){})
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Name (OKEC, Zero)
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (BUF0, Buffer (0x12)
                {
                    /* 0000 */  0x47, 0x01, 0x62, 0x00, 0x62, 0x00, 0x00, 0x01,  // G.b.b...
                    /* 0008 */  0x47, 0x01, 0x66, 0x00, 0x66, 0x00, 0x00, 0x01,  // G.f.f...
                    /* 0010 */  0x79, 0x00                                       // y.
                })
                Name (BUF1, Buffer (0x35)
                {
                    /* 0000 */  0x47, 0x01, 0x62, 0x00, 0x62, 0x00, 0x00, 0x01,  // G.b.b...
                    /* 0008 */  0x47, 0x01, 0x66, 0x00, 0x66, 0x00, 0x00, 0x01,  // G.f.f...
                    /* 0010 */  0x8C, 0x20, 0x00, 0x01, 0x00, 0x01, 0x00, 0x13,  // . ......
                    /* 0018 */  0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00,  // ........
                    /* 0020 */  0x00, 0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x08,  // ...#....
                    /* 0028 */  0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50,  // .\_SB.GP
                    /* 0030 */  0x49, 0x4F, 0x00, 0x79, 0x00                     // IO.y.
                })
                If ((RDHW == Zero))
                {
                    Return (BUF0) /* \_SB_.PCI0.SBRG.EC0_._CRS.BUF0 */
                }
                Else
                {
                    Return (BUF1) /* \_SB_.PCI0.SBRG.EC0_._CRS.BUF1 */
                }
            }

            Method (_REG, 2, NotSerialized)  // _REG: Region Availability
            {
                If ((Arg0 == 0x03))
                {
                    CM80 = DEVS /* \_SB_.PCI0.SBRG.EC0_.DEVS */
                    OKEC = Arg1
                    Notify (ACAD, 0x80) // Status Change
                    Notify (BATT, 0x80) // Status Change
                    Notify (BATT, 0x81) // Information Change
                    Notify (LID, 0x80) // Status Change
                    If (OKEC)
                    {
                        If (!Acquire (Z009, 0x012C))
                        {
                            Local0 = CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                            If ((Local0 & One))
                            {
                                CreateWordField (DPTI, Zero, SSZE)
                                CreateByteField (DPTI, 0x02, MSID)
                                CreateDWordField (DPTI, 0x03, MSDV)
                                SSZE = 0x07
                                MSID = 0x32
                                MSDV = 0x0002AF80
                                ALIB (0x0C, DPTI)
                            }

                            Release (Z009)
                        }
                    }
                }
            }

            OperationRegion (IOCM, SystemIO, 0x72, 0x02)
            Field (IOCM, ByteAcc, NoLock, Preserve)
            {
                CMDX,   8, 
                CMDA,   8
            }

            IndexField (CMDX, CMDA, ByteAcc, NoLock, Preserve)
            {
                Offset (0x80), 
                CM80,   8, 
                CM81,   8
            }

            Mutex (Z009, 0x00)
            Mutex (QEVT, 0x00)
            OperationRegion (ERAM, EmbeddedControl, Zero, 0xFF)
            Field (ERAM, ByteAcc, NoLock, Preserve)
            {
                Offset (0x09), 
                DIEH,   8, 
                Offset (0x45), 
                DEVS,   8, 
                Offset (0x60), 
                CHSH,   8, 
                Offset (0x64), 
                DECL,   8, 
                DECH,   8, 
                DEVL,   8, 
                DEVH,   8, 
                LFCL,   8, 
                LFCH,   8, 
                BTPL,   8, 
                BTPH,   8, 
                BTCL,   8, 
                BTCH,   8, 
                CAPL,   8, 
                CAPH,   8, 
                BTVL,   8, 
                BTVH,   8, 
                Offset (0x74), 
                BCCL,   8, 
                BCCH,   8, 
                BTML,   8, 
                BTMH,   8, 
                BTDL,   8, 
                BTDH,   8, 
                TMPL,   8, 
                TMPH,   8, 
                Offset (0xB0), 
                BCTR,   8
            }

            Method (_Q30, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC30
                If (!Acquire (QEVT, 0x012C))
                {
                    Notify (ACAD, 0x80) // Status Change
                    SMIE = 0xED
                    Local0 = CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                    If ((Local0 & One))
                    {
                        CreateWordField (DPTI, Zero, SSZE)
                        CreateByteField (DPTI, 0x02, MSID)
                        CreateDWordField (DPTI, 0x03, MSDV)
                        SSZE = 0x07
                        MSID = 0x32
                        MSDV = 0x0002AF80
                        ALIB (0x0C, DPTI)
                    }

                    Release (QEVT)
                }
            }

            Method (_Q35, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC35
                If (!Acquire (QEVT, 0x012C))
                {
                    Notify (LID, 0x80) // Status Change
                    Release (QEVT)
                }
            }

            Method (_Q20, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC20
                If (!Acquire (QEVT, 0x012C))
                {
                    Notify (ACAD, 0x80) // Status Change
                    Notify (BATT, 0x80) // Status Change
                    Release (QEVT)
                }
            }

            Method (_Q21, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC21
                If (!Acquire (QEVT, 0x012C))
                {
                    P80H = 0xECE1
                    Notify (BATT, 0x81) // Information Change
                    Sleep (0x0A)
                    Notify (BATT, 0x80) // Status Change
                    Sleep (0x0A)
                    Release (QEVT)
                }
            }

            Method (_Q40, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC40
                If (!Acquire (QEVT, 0x012C))
                {
                    SMIE = 0xEE
                    Release (QEVT)
                }
            }

            Method (_Q41, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC41
                If (!Acquire (QEVT, 0x012C))
                {
                    SMIE = 0xED
                    Local0 = CHSH /* \_SB_.PCI0.SBRG.EC0_.CHSH */
                    If ((Local0 & One))
                    {
                        CreateWordField (DPTI, Zero, SSZE)
                        CreateByteField (DPTI, 0x02, MSID)
                        CreateDWordField (DPTI, 0x03, MSDV)
                        SSZE = 0x07
                        MSID = 0x32
                        MSDV = 0x0002AF80
                        ALIB (0x0C, DPTI)
                    }

                    Release (QEVT)
                }
            }

            Method (_Q55, 0, NotSerialized)  // _Qxx: EC Query, xx=0x00-0xFF
            {
                P80H = 0xEC55
                Notify (AMW0, 0xD2) // Hardware-Specific
            }
        }

        Device (CIND)
        {
            Name (_HID, "INT33D3")  // _HID: Hardware ID
            Name (_CID, "PNP0C60" /* Display Sensor Device */)  // _CID: Compatible ID
            Method (_STA, 0, Serialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Name (_CRS, Buffer (0x26)  // _CRS: Current Resource Settings
            {
                /* 0000 */  0x8C, 0x21, 0x00, 0x01, 0x00, 0x01, 0x00, 0x05,  // .!......
                /* 0008 */  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00,  // ........
                /* 0010 */  0x00, 0x19, 0x00, 0x23, 0x00, 0x00, 0x00, 0x05,  // ...#....
                /* 0018 */  0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50,  // .\_SB.GP
                /* 0020 */  0x49, 0x4F, 0x00, 0x00, 0x79, 0x00               // IO..y.
            })
        }
    }

    Scope (_SB.I2CD)
    {
        Device (STS)
        {
            Name (_HID, EisaId ("SMO8B30"))  // _HID: Hardware ID
            Name (_CID, EisaId ("SMO8B30"))  // _CID: Compatible ID
            Name (_UID, Zero)  // _UID: Unique ID
            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                Return (0x0F)
            }

            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                Name (RBUF, Buffer (0x69)
                {
                    /* 0000 */  0x8E, 0x1D, 0x00, 0x02, 0x00, 0x01, 0x02, 0x00,  // ........
                    /* 0008 */  0x00, 0x01, 0x0A, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                    /* 0010 */  0x6A, 0x00, 0x53, 0x4C, 0x41, 0x30, 0x5C, 0x5F,  // j.SLA0\_
                    /* 0018 */  0x53, 0x42, 0x2E, 0x49, 0x32, 0x43, 0x44, 0x00,  // SB.I2CD.
                    /* 0020 */  0x8E, 0x1D, 0x00, 0x02, 0x00, 0x01, 0x02, 0x00,  // ........
                    /* 0028 */  0x00, 0x01, 0x0A, 0x00, 0x80, 0x1A, 0x06, 0x00,  // ........
                    /* 0030 */  0x6A, 0x00, 0x53, 0x4C, 0x47, 0x30, 0x5C, 0x5F,  // j.SLG0\_
                    /* 0038 */  0x53, 0x42, 0x2E, 0x49, 0x32, 0x43, 0x44, 0x00,  // SB.I2CD.
                    /* 0040 */  0x8C, 0x24, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01,  // .$......
                    /* 0048 */  0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x17, 0x00,  // ........
                    /* 0050 */  0x00, 0x19, 0x00, 0x23, 0x00, 0x04, 0x00, 0x09,  // ...#....
                    /* 0058 */  0x00, 0x5C, 0x5F, 0x53, 0x42, 0x2E, 0x47, 0x50,  // .\_SB.GP
                    /* 0060 */  0x49, 0x4F, 0x00, 0x53, 0x4C, 0x41, 0x30, 0x79,  // IO.SLA0y
                    /* 0068 */  0x00                                             // .
                })
                Return (RBUF) /* \_SB_.I2CD.STS_._CRS.RBUF */
            }

            Method (SLA0, 0, NotSerialized)
            {
                Name (RBUF, Package (0x03)
                {
                    "-1 0 0", 
                    "0 -1 0", 
                    "0 0 -1"
                })
                Return (RBUF) /* \_SB_.I2CD.STS_.SLA0.RBUF */
            }

            Method (SLG0, 0, NotSerialized)
            {
                Name (RBUF, Package (0x03)
                {
                    "1 0 0", 
                    "0 1 0", 
                    "0 0 1"
                })
                Return (RBUF) /* \_SB_.I2CD.STS_.SLG0.RBUF */
            }
        }
    }

    Scope (_SB.PCI0.GP17.XHC0)
    {
        Device (RHUB)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Device (PRT1)
            {
                Name (_ADR, One)  // _ADR: Address
                Device (CAM2)
                {
                    Name (_ADR, One)  // _ADR: Address
                    Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                    {
                        Return (M601 (0x04, Zero, 0x08, Zero, 0x0105, 0x00AF00E1))
                    }
                }

                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (Zero, 0xFF))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x0102, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT2)
            {
                Name (_ADR, 0x02)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (Zero, Zero))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x02, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT3)
            {
                Name (_ADR, 0x03)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (Zero, Zero))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x03, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT4)
            {
                Name (_ADR, 0x04)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, Zero))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, One, 0x04, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT5)
            {
                Name (_ADR, 0x05)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (Zero, Zero))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x05, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT6)
            {
                Name (_ADR, 0x06)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0x09))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x03, One, One, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT7)
            {
                Name (_ADR, 0x07)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0x03))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, One, 0x02, 0x03, 0x0112, Zero))
                }
            }
        }
    }

    Scope (_SB.PCI0.GP17.XHC1)
    {
        Device (RHUB)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Device (PRT1)
            {
                Name (_ADR, One)  // _ADR: Address
                Device (CAM0)
                {
                    Name (_ADR, One)  // _ADR: Address
                    Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                    {
                        Return (M601 (0x04, Zero, 0x08, Zero, 0x0104, 0x00AF00E1))
                    }
                }

                Device (CAM1)
                {
                    Name (_ADR, 0x03)  // _ADR: Address
                    Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                    {
                        Return (M601 (0x04, Zero, 0x08, Zero, 0x0104, 0x00AF00E1))
                    }
                }

                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (Zero, 0xFF))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x0101, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT2)
            {
                Name (_ADR, 0x02)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0xFF))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x0101, 0x03, 0x0112, Zero))
                }
            }
        }
    }

    Scope (_SB.PCI0.GP19.XHC2)
    {
        Device (RHUB)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Device (PRT1)
            {
                Name (_ADR, One)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, Zero))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x08, Zero, 0x0104, Zero))
                }
            }

            Device (PRT2)
            {
                Name (_ADR, 0x02)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (Zero, Zero))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x02, Zero, 0x08, Zero, 0x0104, Zero))
                }
            }
        }
    }

    Scope (_SB.PCI0.GP19.XHC3)
    {
        Device (RHUB)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Device (PRT1)
            {
                Name (_ADR, One)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0x09))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x03, One, 0x0301, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT2)
            {
                Name (_ADR, 0x02)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0x09))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x03, One, 0x0301, 0x03, 0x0112, Zero))
                }
            }
        }
    }

    Scope (_SB.PCI0.GP19.XHC4)
    {
        Device (RHUB)
        {
            Name (_ADR, Zero)  // _ADR: Address
            Device (PRT1)
            {
                Name (_ADR, One)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0x09))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x03, One, 0x0401, 0x03, 0x0112, Zero))
                }
            }

            Device (PRT2)
            {
                Name (_ADR, 0x02)  // _ADR: Address
                Method (_UPC, 0, Serialized)  // _UPC: USB Port Capabilities
                {
                    Return (M600 (One, 0x09))
                }

                Method (_PLD, 0, Serialized)  // _PLD: Physical Location of Device
                {
                    Return (M601 (0x03, One, 0x0401, 0x03, 0x0112, Zero))
                }
            }
        }
    }
}

