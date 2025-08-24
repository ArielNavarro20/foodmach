<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class RecomendarController extends Controller
{
    public function index(Request $request)
    {
        $u   = Auth::user();
        $uid = $u?->id ?? 0;

        // Criterios activos 
        $crit = [
            'enfermedad'  => session('pref.enfermedad')  ?? '',
            'preferencia' => session('pref.preferencia') ?? '',
            'alimento'    => session('pref.alimento')    ?? '',
        ];
        $tags = array_values(array_filter($crit));

        //  para aplicar filtros consistentes
        $applyFilters = function ($q) use ($crit) {
            // Preferencia
            if ($crit['preferencia'] === 'vegano') {
                $q->having('f_animal', '=', 0);
            } elseif ($crit['preferencia'] === 'vegetariano') {
                $q->having('f_carne', '=', 0);
            }

            // Condición de salud
            if ($crit['enfermedad'] === 'celiaco') {
                $q->having('f_gluten', '=', 0);
            } elseif ($crit['enfermedad'] === 'intolerante_lactosa') {
                $q->having('f_lactosa', '=', 0);
            }

            // Tipo 
            if (!empty($crit['alimento'])) {
                $tipo = $crit['alimento'];
                $q->where(function ($w) use ($tipo) {
                    $w->where('m.nombre',         'like', "%{$tipo}%")
                      ->orWhere('m.descripcion',  'like', "%{$tipo}%")
                      ->orWhere('m.caracteristicas','like', "%{$tipo}%");
                });
            }
        };

       
        //  Sugeridos por última compra
        
        $recomendados = collect();

        if ($uid > 0) {
            $last = DB::table('pedidos as p')
                ->join('menus as m', 'm.id', '=', 'p.menu_id')
                ->select('m.id','m.nombre','m.descripcion','m.caracteristicas')
                ->where('p.usuario_id', $uid)
                ->orderByDesc('p.fecha')
                ->first();

            if ($last) {
                // conocidos para matchear similitud por caracteristicas
                $knownTags = ['vegano','vegetar','celiac','gluten','lactosa','sodio','azúcar','grasa','proteín','fibra','diabet','hipertens','bajo en','sin '];
                $wanted = [];
                $lc = mb_strtolower($last->caracteristicas ?? '');
                foreach ($knownTags as $t) {
                    if (mb_strpos($lc, $t) !== false) {
                        $wanted[] = $t;
                    }
                }

                //tipo por nombre
                $tipoNombre = null;
                $ln = mb_strtolower($last->nombre);
                if (str_contains($ln, 'ensalada')) $tipoNombre = 'ensalada';
                elseif (str_contains($ln, 'wrap')) $tipoNombre = 'wrap';
                elseif (str_contains($ln, 'fit')) $tipoNombre = 'fit';

                $sim = DB::table('menus as m')
                    ->leftJoin('restaurantes as r', 'r.id', '=', 'm.restaurante_id')
                    ->leftJoin('menu_ingrediente as mi', 'mi.menu_id', '=', 'm.id')
                    ->leftJoin('ingredientes as ing', 'ing.id', '=', 'mi.ingrediente_id')
                    ->select([
                        'm.id',
                        DB::raw('m.nombre as menu_nombre'),
                        'm.descripcion',
                        'm.caracteristicas',
                        DB::raw("COALESCE(r.nombre,'Personalizados') as restaurante_nombre"),
                        DB::raw("COALESCE(r.direccion,'N/A') as direccion"),
                        DB::raw('COUNT(mi.ingrediente_id) as n_ings'),
                        DB::raw("GROUP_CONCAT(DISTINCT ing.nombre ORDER BY ing.nombre SEPARATOR ', ') as lista_ings"),
                        DB::raw("SUM(ing.es_gluten) as f_gluten"),
                        DB::raw("SUM(ing.es_lactosa) as f_lactosa"),
                        DB::raw("SUM(CASE WHEN ing.categoria='carne' THEN 1 ELSE 0 END) as f_carne"),
                        DB::raw("SUM(ing.es_animal) as f_animal"),
                    ])
                    ->where('m.id', '<>', $last->id)
                    ->groupBy('m.id', 'm.nombre', 'm.descripcion', 'm.caracteristicas', 'r.nombre', 'r.direccion');

                // similitud por tags de caracteristicas
                if (!empty($wanted)) {
                    $scoreSql = '0';
                    foreach ($wanted as $t) {
                        $like = str_replace("'", "''", $t);
                        $scoreSql .= " + (CASE WHEN m.caracteristicas LIKE '%{$like}%' THEN 1 ELSE 0 END)";
                    }
                    $sim->addSelect(DB::raw("$scoreSql as sim_score"))
                        ->orderByDesc('sim_score');
                }

                //tipo si se detectó
                if ($tipoNombre) {
                    $sim->orderByRaw("CASE WHEN m.nombre LIKE ? THEN 1 ELSE 0 END DESC", [$tipoNombre.'%']);
                }

                // aplicar filtros de usuario
                $applyFilters($sim);

                $recomendados = $sim->limit(6)->get();
            }
        }

       
        // otros compatibles igual al home
        
        $otros = DB::table('menus as m')
            ->leftJoin('restaurantes as r', 'r.id', '=', 'm.restaurante_id')
            ->leftJoin('menu_ingrediente as mi', 'mi.menu_id', '=', 'm.id')
            ->leftJoin('ingredientes as ing', 'ing.id', '=', 'mi.ingrediente_id')
            ->select([
                'm.id',
                DB::raw('m.nombre as menu_nombre'),
                'm.descripcion',
                'm.caracteristicas',
                DB::raw("COALESCE(r.nombre,'Personalizados') as restaurante_nombre"),
                DB::raw("COALESCE(r.direccion,'N/A') as direccion"),
                DB::raw('COUNT(mi.ingrediente_id) as n_ings'),
                DB::raw("GROUP_CONCAT(DISTINCT ing.nombre ORDER BY ing.nombre SEPARATOR ', ') as lista_ings"),
                DB::raw("SUM(ing.es_gluten) as f_gluten"),
                DB::raw("SUM(ing.es_lactosa) as f_lactosa"),
                DB::raw("SUM(CASE WHEN ing.categoria='carne' THEN 1 ELSE 0 END) as f_carne"),
                DB::raw("SUM(ing.es_animal) as f_animal"),
            ])
            ->groupBy('m.id', 'm.nombre', 'm.descripcion', 'm.caracteristicas', 'r.nombre', 'r.direccion')
            ->orderByDesc('m.id')
            ->limit(12);

        $applyFilters($otros);
        $otros = $otros->get();

        return view('recomendar.index', [
            'tags'         => $tags,
            'recomendados' => $recomendados,
            'otros'        => $otros,
        ]);
    }
}
