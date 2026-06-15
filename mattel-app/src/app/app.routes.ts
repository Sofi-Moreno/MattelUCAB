import { Routes } from '@angular/router';
import { Designs } from './view/product_designs/designs';
import { Home } from './view/home/home';

export const routes: Routes = [
    {path: '', component:  Home},
    {path: 'designs', component:  Designs}
];
