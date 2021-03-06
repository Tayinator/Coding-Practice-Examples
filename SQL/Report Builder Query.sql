    -------- Employee Info --------
SELECT
    DISTINCT PMEMPLP.EMPID as [Employee Id],
    PMEMPLP.EMFN 'First Name',
    PMEMPLP.EMLN 'Last Name',
    PMEMPLP.EMMAIL 'Email',
    CONVERT(
        VARCHAR(10),
        cast(cast(PMEMPLP.EMDHIR as varchar(10)) as date),
        101
    ) 'Hire Date',
    LEFT(
        CONVERT(
            VARCHAR(10),
            cast(cast(PMEMPLP.EMBDAY as varchar(10)) as date),
            101
        ),
        5
    ) 'Birth Date',

    -------- Role --------
    CASE
        WHEN RTRIM(LTRIM(PMEMPLP.EMPID)) IN (
            '658313',-- Amanda Sawaged
            '652365',-- Alex Gontarek
            '401471',--Donita Kemmerer
            '629605',-- Della Waters
            '510487',-- Michael Paul
            '621155',-- Gina Love
            '676509',-- Josh Adler
            '623859',--Robert Estrada
            '557902',-- Tiffany Lille
            '666340',-- Sam Thomas
            '640280',-- Savannah Camp
            '673025',--Sharon Gruner
            '643376',--Apryl Barrett
            '590909',--Alex Edwards
            '640282',-- Lori Duckworth
            '690509', --Ashley Evans
            '639347' --Brandon Akard
        ) THEN 'Admin'
        WHEN PMEMPLP.EMJBCD = 'DRV' then 'Employee'
        WHEN PMEMPLP.EMJBCD = 'OFF' then 'Group Manager'
        WHEN PMEMPLP.EMJBCD = 'EXE' then 'Executive Manager'
        ELSE ''
    END AS 'Role',
    'US' as 'Country Code',
    PMEMPLP_1.EMPID 'Supervisor Id',
    'en' as 'Language',
    CASE
        WHEN PMEMPLP.EMJBCD = 'DRV' THEN LEFT(PMEMPLP.EMDCG, 1)
        WHEN PMEMPLP.EMJBCD = 'OFF' THEN LEFT(PRPMS.PRL02, 1)
        ELSE ''
    END AS '#Cost Center',
    CASE
        WHEN PMEMPLP.EMJBCD = 'DRV' THEN PCG.PCCGP
        ELSE 'OFFICE'
    END AS '#Payroll Group',
    CASE
        WHEN PMEMPLP.EMJBCD = 'DRV' THEN CGM.CGDSC
        ELSE 'OFFICE'
    END AS '#Payroll Group Description',
    PMEMPLP.EMDCG #ControlGroup,
    PMEMPLP.EMJBCD '#Security Group',
    CASE
        WHEN PMEMPLP.EMJBCD IN ('OFF', 'EXE') THEN PRPMS.PRTITL
        WHEN (
            PMEMPLP.EMJBCD IN ('DRV')
            AND PMEMPLP.EMJBDS = 'DTE'
        ) THEN 'DRIVER TRAINEE'
        WHEN (
            PMEMPLP.EMJBCD IN ('DRV')
            AND PMEMPLP.EMJBDS = 'DTR'
        ) THEN 'DRIVER TRAINER'
        ELSE 'DRIVER'
    END AS '#JobTitle',
    (
        SELECT
            EMPAT_ATT_TXT
        from
            psa.dbo.SMFD35_XPSFILE_EMPATMP
        where
            EMPAT_CO # = PMEMPLP.EMCM and EMPAT_EMP_SS# = PMEMPLP.EMES# and EMPAT_DRV_ATTR = 'AZUREEMAIL') as 'Username',
            '' as 'Password'
        FROM
            psa.dbo.SMFD35_XPSFILE_PMEMPLP PMEMPLP(nolock)
            left join psa.[dbo].[SMFD35_XPSFILE_Payroll_Control_Group] PCG (nolock) ON PMEMPLP.EMES # = PCG.PCSS# 
            AND PCEXPD = '99999999'
            left join PSA.[dbo].[SMFD35_XPSFILE_Control_Group_Master] CGM on CGM.CGCDE = PCG.PCCGP
            AND cgm.CGDIV = pcg.PCDIV
            AND cgm.CGEXPD = '99999999'
            AND CGM.CGTYPE = 'PR'
            left join psa.dbo.smfd35_hrdbfa_prpms PRPMS on CONCAT(0, PMEMPLP.EMCM) = PRPMS.PRER
            and PMEMPLP.EMPID = PRPMS.PREN
            left join psa.dbo.smfd35_hrdbfa_PEPOG PEPOG on PRPMS.PRER = PEPOG.OGER
            AND PRPMS.PRPOS = PEPOG.OGPOS
            left join psa.dbo.SMFD35_XPSFILE_PMEMPLP PMEMPLP_1(nolock) on PMEMPLP.EMCM = PMEMPLP_1.EMCM
            AND PMEMPLP.EMSPES = PMEMPLP_1."EMES#"
            left join psa.dbo.smfd35_hrdbfa_prpms PRPMS_1 on CONCAT(0, PMEMPLP_1.EMCM) = PRPMS_1.PRER
            and PMEMPLP_1.EMPID = PRPMS_1.PREN
        WHERE
            --Family Dollar Duncan, Family Dollar Marianna, Ryder Jacksonville, Walmart Gordonsville
            (
                RTRIM(LTRIM(PMEMPLP.EMPID)) IN (
                    '412791',-- Justin Harness
                    '658313',-- Amanda Sawaged
                    '652365',-- Alex Gontarek
                    '401471',--Donita Kemmerer
                    '629605',-- Della Waters
                    '586527',--Greg Aftung
                    '435174',-- Eric Holcomb
                    '449364',-- Ashley Ellison
                    '585540',-- Adam Poore
                    '548100',-- Shane Weeks
                    '431593',-- Dan Perkins
                    '410340',-- Clayton Kibler
                    '669621',--Matthew Halulko 
                    '510487',-- Michael Paul
                    '621155',-- Gina Love
                    '623859',-- Robert Estrada
                    '557902',--Tiffany Lillie
                    '676509',-- Josh Adler
                    '640280',-- Savannah Smtih
                    '673025',--Sharon Gruner
                    '666340',-- Sam Thomas
                    '643376',--Apryl Barrett
                    '590909',--Alex Edwards
                    '640282', -- Lori Duckworth
                    '690509', --Ashley Evans
                    '639347' --Brandon Akard
                )
            )
            OR (
                (PMEMPLP.EMESTS NOT IN ('ZZ'))
                and PMEMPLP.EMCM IN ('01')
                and PMEMPLP.EMJBDS <> 'DTE'
                AND (
                    (
                        PMEMPLP.EMJBCD in ('drv')
                        AND PMEMPLP.EMDCG LIKE ('D%')
                    )
                    OR (
                        PMEMPLP.EMJBCD in ('OFF', 'EXE')
                        AND PRPMS.PRL02 = ('DED')
                    )
                )
                AND (
                    (
                        PMEMPLP.EMJBCD in ('drv')
                        AND PCG.PCCGP in ('185', '185P', '112', '112P', '280', '303')
                    )
                    OR (
                        PMEMPLP.EMJBCD in ('OFF', 'EXE')
                        AND PRPMS.PRL04 IN ('FFL', 'WGV', 'FOK', 'DPF')
                    )
                )
                AND (
                    PMEMPLP.EMJBCD = 'DRV'
                    OR (
                        PMEMPLP.EMJBCD IN ('OFF')
                        AND PEPOG.OGPLVL IN ('35', '31')
                    )
                )
                AND PMEMPLP.EMDEPT <> 'SHP'
                AND PMEMPLP.EMPCO <> 'XX'
            )