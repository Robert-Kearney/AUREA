function [ xi ] = f_alpha_noise ( m, sigma, alpha )
    hfa = zeros ( 2 * m, 1 );
    hfa(1) = 1.0;
    for j = 2 : m
        hfa(j) = hfa(j-1) * ( 0.5 * alpha + ( j - 2 ) ) / ( j - 1 );
    end
    hfa(m+1:2*m) = 0.0;
    wfa = [ sigma * randn( m, 1 ); zeros( m, 1 ); ];
    [ fh ] = fft( hfa );
    [ fw ] = fft( wfa );
    fh = fh( 1:m + 1 );
    fw = fw( 1:m + 1 );
    fw = fh .* fw;
    fw(1) = fw(1) / 2;
    fw(end) = fw(end) / 2;
    fw = [ fw; zeros(m-1,1); ];
    xi = ifft( fw );
    xi = 2*real( xi(1:m) );
end