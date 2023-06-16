<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

Route::get('/adv_receitassecar', function () {
    return view('receitas_secar.index');
});
Route::get('/', function () {
    return view('welcome');
});
Route::get('/adv_massagem_tantrica', function () {
    return view('massagem.massagem');
});

Route::get('/adv_curcumy', function () {
    return view('curcucalm.curcucalm');
});