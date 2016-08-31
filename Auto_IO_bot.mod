MODULE ioIOIO
    
    PROC VacSwitch()
        ! Switches VacRun 
        IF getVac() = 1 THEN
            SetDO DO10_1, 0;
            SetDO DO10_2, 0;
        ELSE
            SetDO DO10_1, 1;
        ENDIF
    ENDPROC
    
    PROC VacOn()
        ! Turns on VacRun
        SetDO DO10_1, 1;
    ENDPROC
    
    PROC VacOff()
        ! Turns off VacRun
        SetDO DO10_1, 0;
        SetDO DO10_2, 0;
    ENDPROC
    
    PROC VacSuckSwitch()
        ! Switch the vacuum sucking 
        IF getVac() = 1 THEN
            IF getVacSk() = 0 THEN
                SetDO DO10_2, 1;
            ELSE
                SetDO DO10_2, 0;
            ENDIF            
        ELSE
            SetDO DO10_2, 0;
        ENDIF
    ENDPROC
    
    PROC VacSuckOn()
        ! Turns on the vacuum sucking 
        IF getVac() = 1 THEN
            SetDO DO10_2, 1;          
        ELSE
            SetDO DO10_2, 0;
        ENDIF
    ENDPROC

    PROC VacSuckOff()
        ! Turns off the vacuum sucking 
        SetDO DO10_2, 0;          
    ENDPROC
    
    PROC ConSwitch()     
        ! Switch conveyor on or off
        IF DI10_1 = 1 THEN
            IF getConRun() = 1 THEN
                SetDO DO10_3, 0;          
            ELSE
                SetDO DO10_3, 1;
            ENDIF 
        ELSE
            SetDO DO10_3, 0;
        ENDIF       
    ENDPROC
    
    PROC ConOn()       
        ! Turns on conveyor
        IF DI10_1 = 1 THEN
            SetDO DO10_3, 1;
        ELSE
            SetDO DO10_3, 0;
        ENDIF
    ENDPROC
    
    PROC ConOff()
        ! Turns off conveyor
        SetDO DO10_3, 0;
    ENDPROC  
    
    PROC ConDirSwitch()
        ! Change conveyor direction
        IF getConDir() = 1 THEN
            SetDO DO10_4 , 0;          
        ELSE
            SetDO DO10_4 , 1;
        ENDIF
    ENDPROC
    
    PROC ConDir0()
        ! Turns off conveyor
        SetDO DO10_4, 0;
    ENDPROC 
    
    PROC ConDir1()
        ! Turns off conveyor
        SetDO DO10_4, 1;
    ENDPROC
    
    FUNC dionum getVac()
        RETURN DO10_1; 
    ENDFUNC
    
    FUNC dionum getVacSk()
        RETURN DO10_2; 
    ENDFUNC
    
    FUNC dionum getConRun()
        RETURN DO10_3; 
    ENDFUNC
    
    FUNC dionum getConDir()
        RETURN DO10_4; 
    ENDFUNC
      
ENDMODULE