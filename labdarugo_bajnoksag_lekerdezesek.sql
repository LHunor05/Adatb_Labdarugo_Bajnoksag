--Csapatonként a gólok, lövések száma és a gólok/lövesek aránya százalékban.
SELECT 
    c.nev AS 'Csapat neve',
    SUM(CASE 
        WHEN m.hazai_csapat_id = c.csapat_id THEN e.hazai_gol 
        WHEN m.vendeg_csapat_id = c.csapat_id THEN e.vendeg_gol 
        
    END) AS 'Gólok száma',
    SUM(CASE 
        WHEN m.hazai_csapat_id = c.csapat_id THEN s.hazai_loves 
        WHEN m.vendeg_csapat_id = c.csapat_id THEN s.vendeg_loves 
        
    END) AS 'Lövések száma',
    CASE 
        WHEN SUM(CASE 
                    WHEN m.hazai_csapat_id = c.csapat_id THEN s.hazai_loves 
                    WHEN m.vendeg_csapat_id = c.csapat_id THEN s.vendeg_loves 
                    
                END) = 0 THEN 0
        ELSE CAST(
            SUM(CASE 
                    WHEN m.hazai_csapat_id = c.csapat_id THEN e.hazai_gol 
                    WHEN m.vendeg_csapat_id = c.csapat_id THEN e.vendeg_gol 
                    
                END) * 100.0 / 
            SUM(CASE 
                    WHEN m.hazai_csapat_id = c.csapat_id THEN s.hazai_loves 
                    WHEN m.vendeg_csapat_id = c.csapat_id THEN s.vendeg_loves 
                     
                END) 
            AS DECIMAL(5,2))
    END AS 'Gól/Lövés arány (%)'
FROM 
    Csapatok c
LEFT JOIN 
    Merkozesek m ON c.csapat_id = m.hazai_csapat_id OR c.csapat_id = m.vendeg_csapat_id
LEFT JOIN 
    Eredmenyek e ON m.merkozes_id = e.merkozes_id
LEFT JOIN 
    Statisztikak s ON m.merkozes_id = s.merkozes_id
GROUP BY 
    c.csapat_id, c.nev
ORDER BY 
    'Gólok száma' DESC;






--Összesítő táblázat, végső sorrend alapján.
SELECT 
    c.nev AS 'Csapat',
    SUM(CASE
        WHEN m.hazai_csapat_id = c.csapat_id AND e.hazai_gol > e.vendeg_gol THEN 3
        WHEN m.vendeg_csapat_id = c.csapat_id AND e.vendeg_gol > e.hazai_gol THEN 3
        WHEN e.hazai_gol = e.vendeg_gol THEN 1
        ELSE 0
    END) AS 'Pontok',
    
    SUM(CASE
        WHEN m.hazai_csapat_id = c.csapat_id AND e.hazai_gol > e.vendeg_gol THEN 1
        WHEN m.vendeg_csapat_id = c.csapat_id AND e.vendeg_gol > e.hazai_gol THEN 1
        ELSE 0
    END) AS 'Győzelmek',
    SUM(CASE
        WHEN e.hazai_gol = e.vendeg_gol THEN 1
        ELSE 0
    END) AS 'Döntetlenek',
     SUM(CASE
        WHEN m.hazai_csapat_id = c.csapat_id AND e.hazai_gol < e.vendeg_gol THEN 1
        WHEN m.vendeg_csapat_id = c.csapat_id AND e.vendeg_gol < e.hazai_gol THEN 1
        ELSE 0
    END) AS 'Vereségek',
    SUM(CASE
        WHEN m.hazai_csapat_id = c.csapat_id THEN e.hazai_gol
        ELSE e.vendeg_gol
    END) AS 'gólok'
FROM 
    Csapatok c
LEFT JOIN 
    Merkozesek m ON c.csapat_id = m.hazai_csapat_id OR c.csapat_id = m.vendeg_csapat_id
LEFT JOIN 
    Eredmenyek e ON m.merkozes_id = e.merkozes_id
GROUP BY 
    c.csapat_id, c.nev
ORDER BY 
    'Pontok' DESC





--Legnagyobb gólkülönbségű mérközés és annak adatai.
SELECT TOP 1
    c1.nev AS 'Hazaicsapat',
    c2.nev AS 'Vendégcsapat',
    e.hazai_gol AS 'Hazai gólok',
    e.vendeg_gol AS 'Vendéggólok',
    ABS(e.hazai_gol - e.vendeg_gol) AS 'Gólkülönbság',
    m.datum AS 'Dátum',
    f.fordulo_szam AS 'Forduló'
FROM 
    Eredmenyek e
JOIN 
    Merkozesek m ON e.merkozes_id = m.merkozes_id
JOIN 
    Csapatok c1 ON m.hazai_csapat_id = c1.csapat_id
JOIN 
    Csapatok c2 ON m.vendeg_csapat_id = c2.csapat_id
JOIN
    Fordulok f ON m.fordulo_id = f.fordulo_id
ORDER BY 
    ABS(e.hazai_gol - e.vendeg_gol) DESC
    




--A bajnok Dortmund mérkőzéseinek összesítése és végeredménye.
SELECT 
    M.datum AS dátum,
    CASE 
        WHEN C1.nev = 'Dortmund' THEN 'Hazai'
        ELSE 'Vendég'
    END AS Dortmund,
    CASE 
        WHEN C1.nev = 'Dortmund' THEN C2.nev
        ELSE C1.nev
    END AS ellenfel,
    E.hazai_gol,
    E.vendeg_gol,
    CASE 
        WHEN (C1.nev = 'Dortmund' AND E.hazai_gol > E.vendeg_gol) OR
             (C2.nev = 'Dortmund' AND E.vendeg_gol > E.hazai_gol)
            THEN 'Gyozelem'
        WHEN E.hazai_gol = E.vendeg_gol
            THEN 'Dontetlen'
        ELSE 'Vereseg'
    END AS Dortmund_eredménye
FROM Merkozesek M
JOIN Csapatok C1 ON M.hazai_csapat_id = C1.csapat_id
JOIN Csapatok C2 ON M.vendeg_csapat_id = C2.csapat_id
JOIN Eredmenyek E ON M.merkozes_id = E.merkozes_id
WHERE C1.nev = 'Dortmund' OR C2.nev = 'Dortmund'
ORDER BY M.datum;




--Leggólgazdagabb mérkőzés, amely döntetlenre végződött, és annak az adatai.
SELECT TOP 1
    C1.nev AS hazai_csapat,
    C2.nev AS vendeg_csapat,
    E.hazai_gol,
    E.vendeg_gol,
    (E.hazai_gol + E.vendeg_gol) AS osszes_gol,
    F.fordulo_szam,
    M.datum AS merkozes_datum
FROM Merkozesek M
JOIN Eredmenyek E ON M.merkozes_id = E.merkozes_id
JOIN Csapatok C1 ON M.hazai_csapat_id = C1.csapat_id
JOIN Csapatok C2 ON M.vendeg_csapat_id = C2.csapat_id
JOIN Fordulok F ON M.fordulo_id = F.fordulo_id
WHERE E.hazai_gol = E.vendeg_gol
ORDER BY osszes_gol DESC;





--Legsportszerűtlenebb csapat, amelyet az összegyűjtött piros- és sárgalapok alapján határoztunk meg. Továbbá a csapat végső adatai.
WITH LapokOsszesitve AS (
    SELECT
        C.csapat_id,
        C.nev,
        SUM(CASE WHEN M.hazai_csapat_id = C.csapat_id THEN S.hazai_sarga ELSE S.vendeg_sarga END) +
        SUM(CASE WHEN M.hazai_csapat_id = C.csapat_id THEN S.hazai_piros ELSE S.vendeg_piros END) AS osszes_lap
    FROM Csapatok C
    JOIN Merkozesek M ON C.csapat_id = M.hazai_csapat_id OR C.csapat_id = M.vendeg_csapat_id
    JOIN Statisztikak S ON M.merkozes_id = S.merkozes_id
    GROUP BY C.csapat_id, C.nev
),
PontokSzamitva AS (
    SELECT
        C.csapat_id,
        C.nev,
        SUM(
            CASE 
                WHEN C.csapat_id = M.hazai_csapat_id AND E.hazai_gol > E.vendeg_gol THEN 3
                WHEN C.csapat_id = M.vendeg_csapat_id AND E.vendeg_gol > E.hazai_gol THEN 3
                WHEN (C.csapat_id = M.hazai_csapat_id OR C.csapat_id = M.vendeg_csapat_id) AND E.hazai_gol = E.vendeg_gol THEN 1
                ELSE 0
            END
        ) AS pont
    FROM Csapatok C
    JOIN Merkozesek M ON C.csapat_id = M.hazai_csapat_id OR C.csapat_id = M.vendeg_csapat_id
    JOIN Eredmenyek E ON M.merkozes_id = E.merkozes_id
    GROUP BY C.csapat_id, C.nev
),
LapokPonttal AS (
    SELECT
        L.nev AS név,
        L.osszes_lap,
        P.pont,
        RANK() OVER (ORDER BY P.pont DESC) AS helyezes
    FROM LapokOsszesitve L
    JOIN PontokSzamitva P ON L.csapat_id = P.csapat_id
)
SELECT TOP 1 *
FROM LapokPonttal
ORDER BY osszes_lap DESC;

