<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class HomeController extends Controller
{
    public function index(Request $request)
    {
        // Prefill del formulario (desde sesión)
        $lastPref = [
            'nombre'      => session('pref.nombre', ''),
            'edad'        => session('pref.edad', ''),
            'direccion'   => session('pref.direccion', ''),
            'envio'       => session('pref.envio', 'sí'),
            'enfermedad'  => session('pref.enfermedad', ''),
            'preferencia' => session('pref.preferencia', ''),
            'alimento'    => session('pref.alimento', ''),
        ];

        // Criterios actuales para criterios y filtrar consutlas
        $crit = [
            'enfermedad'  => $lastPref['enfermedad'] ?? '',
            'preferencia' => $lastPref['preferencia'] ?? '',
            'alimento'    => $lastPref['alimento'] ?? '',
        ];

        $segunCompra = collect();
        $otros       = collect();

        if (Auth::check()) {
            $uid = Auth::id();

            // filtros para recomendarcontroller
            $applyFilters = function ($q) use ($crit) {
                // Preferencias
                if ($crit['preferencia'] === 'vegano') {
                    $q->having('f_animal', '=', 0);
                } elseif ($crit['preferencia'] === 'vegetariano') {
                    $q->having('f_carne', '=', 0);
                }

                // Condiciones
                if ($crit['enfermedad'] === 'celiaco') {
                    $q->having('f_gluten', '=', 0);
                } elseif ($crit['enfermedad'] === 'intolerante_lactosa') {
                    $q->having('f_lactosa', '=', 0);
                }
                // (hipertenso/diabético/cardiaco

                // Tipo de alimento 
                if (!empty($crit['alimento'])) {
                    $tipo = $crit['alimento'];
                    $q->where(function ($w) use ($tipo) {
                        $w->where('m.nombre', 'like', "%{$tipo}%")
                          ->orWhere('m.descripcion', 'like', "%{$tipo}%")
                          ->orWhere('m.caracteristicas', 'like', "%{$tipo}%");
                    });
                }
            };

            // Recomendados según compra anterior 
            if (!session('pref.ignorar_historial')) {
                $qHist = DB::table('pedidos as p')
                    ->join('menus as m', 'm.id', '=', 'p.menu_id')
                    ->leftJoin('restaurantes as r', 'r.id', '=', 'm.restaurante_id')
                    ->leftJoin('menu_ingrediente as mi', 'mi.menu_id', '=', 'm.id')
                    ->leftJoin('ingredientes as ing', 'ing.id', '=', 'mi.ingrediente_id')
                    ->where('p.usuario_id', $uid)
                    ->select([
                        'm.id',
                        'm.nombre as menu_nombre',
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
                        DB::raw('MAX(p.fecha) as ultima_fecha'),
                    ])
                    ->groupBy('m.id','m.nombre','m.descripcion','m.caracteristicas','r.nombre','r.direccion')
                    ->orderByDesc('ultima_fecha')
                    ->limit(6);

                $applyFilters($qHist);
                $segunCompra = $qHist->get();
            }

            //  Otros menús compatibles
            $qOtros = DB::table('menus as m')
                ->leftJoin('restaurantes as r', 'r.id', '=', 'm.restaurante_id')
                ->leftJoin('menu_ingrediente as mi', 'mi.menu_id', '=', 'm.id')
                ->leftJoin('ingredientes as ing', 'ing.id', '=', 'mi.ingrediente_id')
                ->leftJoin('pedidos as p', 'p.menu_id', '=', 'm.id')
                ->select([
                    'm.id',
                    'm.nombre as menu_nombre',
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
                    DB::raw('COUNT(p.id) as popularidad'),
                ])
                ->groupBy('m.id','m.nombre','m.descripcion','m.caracteristicas','r.nombre','r.direccion')
                ->orderByDesc('popularidad')
                ->limit(12);

            $applyFilters($qOtros);
            $otros = $qOtros->get();
        }

        return view('home.index', [
            'lastPref'      => $lastPref,
            'segunCompra'   => $segunCompra,
            'otros'         => $otros,
            'criterios'     => array_filter($crit),
            'ignoraHist'    => (bool)session('pref.ignorar_historial'),
        ]);
    }

    public function guardarPreferencias(Request $request)
    {
        $data = $request->validate([
            'nombre'      => 'required|string|max:120',
            'edad'        => 'required|integer|min:1|max:120',
            'direccion'   => 'required|string|max:255',
            'envio'       => 'required|in:sí,no',
            'enfermedad'  => 'nullable|string|max:60',
            'preferencia' => 'nullable|string|max:60',
            'alimento'    => 'nullable|string|max:100',
        ]);

        foreach ($data as $k => $v) {
            session(["pref.$k" => $v]);
        }

        return redirect()->route('recomendar');
    }

    // botones
    public function ignorarHistorial()
    {
        session(['pref.ignorar_historial' => true]);
        return back();
    }

    public function usarHistorial()
    {
        session()->forget('pref.ignorar_historial');
        return back();
    }

    public function limpiarHistorial()
    {
        $uid = Auth::id();
        if ($uid) {
            DB::table('pedidos')->where('usuario_id', $uid)->delete();
        }
        return back()->with('ok', 'Historial de compras eliminado.');
    }
}
