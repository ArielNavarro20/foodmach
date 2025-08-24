<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class MenuController extends Controller
{
    //formulario del builder
    public function builderForm(Request $r)
    {
        // Lo que el usuario eligió en el formulario principal
        $pref = session('pref.preferencia', '');          
        $cond = session('pref.enfermedad', '');          

        // Base de la consulta
        $q = DB::table('ingredientes');

        
        // vegano: nada de origen animal ni lactosa
        if ($pref === 'vegano') {
            $q->where('es_animal', 0)->where('es_lactosa', 0);
        }
        // vegetariano sin carnes y se permite lacteos y huevos 
        elseif ($pref === 'vegetariano') {
            $q->where('categoria', '!=', 'carne');
        }
        // “celiaco” sin gluten
        elseif ($pref === 'celiaco') {
            $q->where('es_gluten', 0);
        }

       
        // Filtros por condición
       
        if ($cond === 'celiaco') {
            $q->where('es_gluten', 0);
        }
        if ($cond === 'intolerante a la lactosa') {
            $q->where('es_lactosa', 0);
        }

        
        if ($cond === 'hipertenso') {         // bajo sodio
            $q->where('sodio_mg', '<=', 120);
        }
        if ($cond === 'diabetico') {          // bajo azúcar
            $q->where('azucar', '<=', 5);
        }
        if ($cond === 'cardiaco') {           // bajo grasa
            $q->where('grasa', '<=', 5);
        }

        // Obtener e ir agrupando por categoría para la vista
        $ings = $q->orderBy('categoria')->orderBy('nombre')->get();

        $grupos = [];
        foreach ($ings as $ing) {
            $grupos[$ing->categoria][] = $ing;
        }

        // Para que la vista pueda mostrar qué filtros se aplicaron
        $filtrosActivos = [
            'preferencia' => $pref ?: '—',
            'condicion'   => $cond ?: '—',
        ];

        return view('builder.form', compact('grupos', 'filtrosActivos'));
    }

    
    
    public function builderCrear(Request $r)
    {
        $r->validate([
            'ingrediente_id' => 'required|array|min:1',
            'ingrediente_id.*' => 'integer',
            'gramos' => 'required|array',
            'gramos.*' => 'nullable|numeric|min:1|max:2000',
        ]);

        $ids    = $r->input('ingrediente_id', []);
        $gramos = $r->input('gramos', []);

        if (!Auth::check()) {
            return redirect()->route('login.form');
        }

        //  restaurante Personalizados
        $rest = DB::table('restaurantes')->where('nombre', 'Personalizados')->first();
        if (!$rest) {
            $rid = DB::table('restaurantes')->insertGetId([
                'nombre'   => 'Personalizados',
                'direccion'=> 'N/A',
                'tipo'     => 'virtual',
            ]);
            $rest = (object)['id' => $rid];
        }

        // Crear menú personalizado
        $u = Auth::user();
        $menuNombre = 'Menú personalizado de ' . ($u->nombre ?? $u->email) . ' - ' . date('Y-m-d H:i');
        $desc = 'Construido con ' . count($ids) . ' ingrediente(s)';
        $menuId = DB::table('menus')->insertGetId([
            'restaurante_id' => $rest->id,
            'nombre'         => $menuNombre,
            'descripcion'    => $desc,
            'caracteristicas'=> 'personalizado',
        ]);

        // Pivot ingredientes
        foreach ($ids as $k => $ingId) {
            $g = isset($gramos[$k]) ? max(1, min(2000, (float)$gramos[$k])) : 100;
            DB::table('menu_ingrediente')->insert([
                'menu_id'        => $menuId,
                'ingrediente_id' => (int)$ingId,
                'gramos'         => $g,
            ]);
        }

        // Crear pedido con los datos del formulario guardados en sesión
        $pref = [
            'nombre_form'       => session('pref.nombre'),
            'edad_form'         => session('pref.edad'),
            'direccion_form'    => session('pref.direccion'),
            'envio_form'        => session('pref.envio'),
            'enfermedad_form'   => session('pref.enfermedad'),
            'preferencia_form'  => session('pref.preferencia'),
            'alimento_form'     => session('pref.alimento'),
        ];

        DB::table('pedidos')->insert(array_merge([
            'usuario_id' => Auth::id(),
            'menu_id'    => $menuId,
        ], $pref));

        return redirect()->route('mis.pedidos')->with('msg', '¡Menú creado y pedido generado!');
    }
}
